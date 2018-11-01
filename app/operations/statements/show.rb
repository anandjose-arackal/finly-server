class Statements::Show < Statements::Base
  attr_accessor :account, :finly_transactions

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:statement_type).blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    # todo Jugaad to counter url id issue
    params[:id] = params[:user_id]

    statement_type = params[:statement_type]&.to_sym
    account_type = params[:account_type]&.to_sym

    pocket_id = params[:user_pocket_id] # in case the statements are being requested for a user's pocket

    case statement_type
      when :company
        case account_type
          when :card_transfer_credits
            self.account = user.company.itz_cash_company_account
          when :bank_transfer_credits
            self.account = user.company.yes_bank_company_account
        end
      when :user
        user_presenter = User::Show.(user, params)
        unless user_presenter.success?
          add_message :error, user_presenter.messages[:error]
          return
        end
        sel_user = user_presenter.selected_user
        case account_type
          when :expense_card
            self.account = sel_user.cards.expense_cards.first
          when :reimbursement_card
            self.account = sel_user.cards.reimbursement_cards.first
          when :finly_money_card_transfer
            self.account = sel_user.wallet
          when :finly_money_bank_transfer
            self.account = sel_user.bank_wallet
          when :cash_on_hand
            self.account = sel_user.cash_on_hand
          when :user_pocket
            self.account = sel_user.user_pockets.find_by(id: pocket_id)
        end
      when :card
        user_presenter = User::Index.(user, params)
        unless user_presenter.success?
          add_message :error, user_presenter.messages[:error]
          return
        end
        users = user_presenter.team
        self.account = Card.with_user(users.pluck(:id)).with_proxy(params[:proxy])&.first
    end

    if params[:with_date_range].nil?
      params[:with_date_range] = {}
    end
    if params[:with_date_range][:from].blank?
      params[:with_date_range][:from] = 30.days.ago.end_of_day
    else
      params[:with_date_range][:from] = Date.parse(params[:with_date_range][:from]).end_of_day
    end
    if params[:with_date_range][:to].blank? or DateUtils.parse_date(params[:with_date_range][:to]) >= Date.today
      params[:with_date_range][:to] = Date.today.end_of_day
    else
      params[:with_date_range][:to] = Date.parse(params[:with_date_range][:to]).end_of_day
    end
  end

  def validate
    if self.account.blank?
      add_message :error, 'Account not found'
    end
  end

  def process
    self.finly_transactions = self.account.finly_transactions
  end

  def success
    params[:finly_transactions] = self.finly_transactions
    params[:account] = self.account
    Statements::Show::SuccessPresenter.new(user, params, messages)
  end

  class Statements::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :finly_transactions, :account, :scoped_finly_transactions,
                  :credit_amount_value, :debit_amount_value, :credit_count_value, :debit_count_value, :summary_data

    has_scope :with_date_range, using: [:from, :to], type: :hash

    def init
      self.account = params[:account]
      self.finly_transactions = params[:finly_transactions]
      self.scoped_finly_transactions = apply_scopes(params[:finly_transactions], params)
      self.credit_amount_value = credit_amount
      self.debit_amount_value = debit_amount
      self.credit_count_value = credits_count
      self.debit_count_value = debits_count
      self.summary_data = summary
      self.scoped_finly_transactions = self.scoped_finly_transactions.include_for_export
    end

    def account_transactions
      page_size = (params&.dig(:page_size) || 30)
      if can_view_transactions?
        return self.scoped_finly_transactions&.paginate(page: params[:page], per_page: page_size)
      elsif can_view_credit? and can_view_debit?
        return self.scoped_finly_transactions.through_finly_dashboard&.paginate(page: params[:page], per_page: page_size)
      elsif can_view_debit?
        return self.scoped_finly_transactions.through_finly_dashboard.debits&.paginate(page: params[:page], per_page: page_size)
      elsif can_view_credit?
        return self.scoped_finly_transactions.through_finly_dashboard.credits&.paginate(page: params[:page], per_page: page_size)
      end
      FinlyTransaction.none
    end

    def credits_count
      return nil unless can_view_credit?
      if can_view_transactions?
        self.scoped_finly_transactions.credits.success.count || 0
      else
        self.scoped_finly_transactions.credits.success.through_finly_dashboard.count || 0
      end
    end

    def debits_count
      return nil unless can_view_debit?
      if can_view_transactions?
        self.scoped_finly_transactions.debits.success.count || 0
      else
        self.scoped_finly_transactions.debits.success.through_finly_dashboard.count || 0
      end
    end

    def opening_balance
      return nil unless can_view_balance?
      date = params&.dig(:with_date_range)&.dig(:from)
      account.opening_balance(date)
    end

    def closing_balance
      return nil unless can_view_balance?
      date = params&.dig(:with_date_range)&.dig(:to)
      account.closing_balance(date)
    end

    def credit_amount
      return nil unless can_view_credit?
      if can_view_transactions?
        self.scoped_finly_transactions.credits.success.sum_amounts || 0
      else
        self.scoped_finly_transactions.credits.success.through_finly_dashboard.sum_amounts || 0
      end
    end

    def debit_amount
      return nil unless can_view_debit?
      if can_view_transactions?
        self.scoped_finly_transactions.debits.success.sum_amounts || 0
      else
        self.scoped_finly_transactions.debits.success.through_finly_dashboard.sum_amounts || 0
      end
    end

    def account_name
      account_name = AccountManagerUtils.name_for self.account
      if [UserWallet.name, CashOnHand.name, Card.name, UserPocket.name].include? self.account.class.name
        if user == self.account.user
          account_name = "Your #{account_name}"
        else
          account_name = "#{self.account.user.name}'s #{account_name}"
        end
      end
      account_name
    end

    def merchant(finly_transaction)
      merchant = ''
      if finly_transaction.credit?
        prefix = 'From '
      else
        prefix = 'To '
      end
      case finly_transaction.payment_purpose_id
        when PaymentPurpose.id_for(:atm_withdrawal), PaymentPurpose.id_for(:personal_expense), PaymentPurpose.id_for(:card_transaction)
          merchant = finly_transaction&.associated_transaction&.merchant_name
        when PaymentPurpose.id_for(:vendor_payment)
          merchant = finly_transaction.payment&.receiving_user&.name
          if merchant.present?
            if finly_transaction.credit?
              merchant = "Reversal for #{merchant}'s Payment"
            elsif finly_transaction.debit?
              merchant = "Sent to #{merchant}"
            end
          else
            merchant = 'Vendor Payment'
          end
        when PaymentPurpose.id_for(:corporate_balance_load)
          merchant = 'Corporate Balance Load'
        when PaymentPurpose.id_for(:corporate_balance_refund)
          refund_payment = finly_transaction.payment
          original_payment = refund_payment.original_payment_for_refund
          original_beneficiary = original_payment&.receiving_user&.name
          merchant = "Refund for #{original_beneficiary}'s payment. Payment ID: #{original_payment.id}" if original_beneficiary.present?
        when PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:reimbursement_outside_finly), PaymentPurpose.id_for(:advance), PaymentPurpose.id_for(:balance_clearance),
            PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:medical_benefit), PaymentPurpose.id_for(:meal_benefit), PaymentPurpose.id_for(:payroll), PaymentPurpose.id_for(:balance_clearance_outside_finly),
            PaymentPurpose.id_for(:cash_advance)
          if finly_transaction.payment.blank?
            if finly_transaction.associated_transaction.class.name == CompanyTransaction.name
              merchant = finly_transaction.associated_transaction.merchant_name
            end
          else
            if finly_transaction.payment.initiating_account == finly_transaction.finly_account and finly_transaction.payment.receiving_account.present?
              merchant = prefix
              merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.receiving_account)}"
            elsif finly_transaction.payment.receiving_account == finly_transaction.finly_account and finly_transaction.payment.initiating_account.present?
              merchant = prefix
              merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.initiating_account)}"
            end
          end
        when PaymentPurpose.id_for(:corporate_account_reload), PaymentPurpose.id_for(:payment_receivable), PaymentPurpose.id_for(:invoice), PaymentPurpose.id_for(:finly_money_reload)
          merchant = "Virtual Account: "
          if finly_transaction.associated_transaction&.virtual_account&.name.present?
            merchant += "#{finly_transaction.associated_transaction&.virtual_account&.name} - "
          end
          merchant += finly_transaction.associated_transaction&.virtual_account&.account_number
      end
      merchant
    end

    def summary
      FinlyTransaction::Summary.(user, finly_transactions: self.scoped_finly_transactions).summary
    end

    def can_view_transactions?
      if self.account.class.name == Card.name and not self.account.card_program.manager_view_transactions and not personal_view? and user != self.account.user
        return false
      end
      true
    end

    def can_view_credit?
      if self.account.class.name == Card.name and not self.account.card_program.manager_credit and not personal_view? and user != self.account.user
        return false
      end
      true
    end

    def can_view_debit?
      if self.account.class.name == Card.name and not self.account.card_program.manager_debit and not personal_view? and user != self.account.user
        return false
      end
      true
    end

    def can_view_balance?
      if self.account.class.name == Card.name and not self.account.card_program.manager_view_balance and not personal_view? and user != self.account.user
        return false
      end
      true
    end

  end

end
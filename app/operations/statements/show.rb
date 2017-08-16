class Statements::Show < BaseOperation
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
    case statement_type
      when :company
        self.account = user.company.itz_cash_company_account
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
          when :finly_money
            self.account = sel_user.wallet
          when :cash_on_hand
            self.account = sel_user.cash_on_hand
        end
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
    attr_accessor :finly_transactions, :account, :scoped_finly_transactions

    has_scope :with_date_range, using: [:from, :to], type: :hash

    def init
      self.account = params[:account]
      self.finly_transactions = params[:finly_transactions]
      self.scoped_finly_transactions = apply_scopes(params[:finly_transactions], params)&.paginate(page: params[:page], per_page: 30)
    end

    def account_transactions
      if can_view_transactions?
        return self.scoped_finly_transactions
      elsif can_view_credit? and can_view_debit?
        return self.scoped_finly_transactions.through_finly_dashboard
      elsif can_view_debit?
        return self.scoped_finly_transactions.through_finly_dashboard.debits
      elsif can_view_credit?
        return self.scoped_finly_transactions.through_finly_dashboard.credits
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
      balance = self.scoped_finly_transactions.last&.opening_balance&.value
      return balance unless balance.nil?

      # todo Jugaad to access historical data
      from = (params&.dig(:with_date_range)&.dig(:from) - 1.day)
      case self.account.class.name
        when Card.name
          self.account.user.user_balance_histories.with_date(from)&.first&.card_balance&.value || 0
        when ItzCashCompanyAccount.name
          self.account.company.company_balance_histories.with_date(from)&.first&.company_balance&.value || 0
        when UserWallet.name
          self.account.user.user_balance_histories.with_date(from)&.first&.finly_money_balance&.value || 0
        when CashOnHand.name
          self.account.user.user_balance_histories.with_date(from)&.first&.cash_on_hand_balance&.value || 0
      end
      # self.account.user.user_balance_histories.with_date(from)&.first.card_balance.value.to_s
    end

    def closing_balance
      return nil unless can_view_balance?
      balance = self.scoped_finly_transactions.first&.closing_balance&.value
      return balance unless balance.nil?

      # todo Jugaad to access historical data
      to = params&.dig(:with_date_range)&.dig(:to)
      case self.account.class.name
        when Card.name
          self.account.user.user_balance_histories.with_date(to)&.first&.card_balance&.value || 0
        when ItzCashCompanyAccount.name
          self.account.company.company_balance_histories.with_date(to)&.first&.company_balance&.value || 0
        when UserWallet.name
          self.account.user.user_balance_histories.with_date(to)&.first&.finly_money_balance&.value || 0
        when CashOnHand.name
          self.account.user.user_balance_histories.with_date(to)&.first&.cash_on_hand_balance&.value || 0
      end
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
      if [UserWallet.name, CashOnHand.name, Card.name].include? self.account.class.name
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
          merchant = 'Vendor Payment'
        when PaymentPurpose.id_for(:corporate_balance_load)
          merchant = 'Corporate Balance Load'
        when PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:reimbursement_outside_finly), PaymentPurpose.id_for(:advance), PaymentPurpose.id_for(:balance_clearance),
            PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:medical_benefit), PaymentPurpose.id_for(:meal_benefit), PaymentPurpose.id_for(:payroll), PaymentPurpose.id_for(:balance_clearance_outside_finly)
          if finly_transaction.payment.blank?
            if finly_transaction.associated_transaction.class.name == CompanyTransaction.name
              merchant = finly_transaction.associated_transaction.merchant_name
            end
          else
            if finly_transaction.payment.initiating_account == finly_transaction.finly_account and finly_transaction.payment.receiving_account.present?
              merchant = prefix
              if [UserWallet, Card].include? finly_transaction.payment.receiving_account.class
                merchant += "#{finly_transaction.payment.receiving_account.user.name}'s "
              end
              merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.receiving_account)}"
            elsif finly_transaction.payment.receiving_account == finly_transaction.finly_account and finly_transaction.payment.initiating_account.present?
              merchant = prefix
              if [UserWallet, Card].include? finly_transaction.payment.initiating_account.class
                merchant += "#{finly_transaction.payment.initiating_account.user.name}'s "
              end
              merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.initiating_account)}"
            end
          end
      end
      merchant
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
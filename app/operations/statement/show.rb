class Statement::Show < BaseOperation
  attr_accessor :account, :finly_transactions, :card_transactions

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
        sel_user = user_presenter.user
        case account_type
          when :expense_card
            self.account = sel_user.cards.expense_cards.first
          when :reimbursement_card
            self.account = sel_user.cards.reimbursement_cards.first
          when :finly_money
            self.account = sel_user.wallet
        end
    end

    if params[:with_date_range].nil?
      params[:with_date_range] = {}
    end
    if params[:with_date_range][:from].blank?
      params[:with_date_range][:from] = 30.days.ago
    end
    if params[:with_date_range][:to].blank? or DateUtils.parse_date(params[:with_date_range][:to]) == Date.today
      params[:with_date_range][:to] = Date.tomorrow
    end
  end

  def validate
    if self.account.blank?
      add_message :error, 'Account not found'
    end
  end

  def process
    self.finly_transactions = FinlyTransaction.with_account(self.account)
    if self.account.class.name == 'Card'
      self.card_transactions = self.account.transactions
    end
  end

  def success
    params[:finly_transactions] = self.finly_transactions
    params[:account] = self.account
    params[:card_transactions] = self.card_transactions
    Statement::Show::SuccessPresenter.new(user, params, messages)
  end

  class Statement::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :finly_transactions, :account, :card_transactions, :scoped_finly_transactions, :scoped_card_transactions

    has_scope :with_date_range, using: [:from, :to], type: :hash

    def init
      self.account = params[:account]
      self.finly_transactions = params[:finly_transactions]
      self.scoped_finly_transactions = apply_scopes(params[:finly_transactions], params)&.paginate(page: params[:page], per_page: 30)
      self.card_transactions = params[:card_transactions]
      if self.card_transactions.present?
        self.scoped_card_transactions = apply_scopes(self.card_transactions, params)&.paginate(page: params[:page], per_page: 30)
      end
    end

    def credits_count
      return if self.finly_transactions.nil? or self.account.nil?
      self.finly_transactions.credits.count
    end

    def debits_count
      return if self.finly_transactions.nil? or self.account.nil?
      self.finly_transactions.debits.count
    end

    def opening_balance
      self.finly_transactions.last&.opening_balance&.value&.to_s
    end

    def closing_balance
      self.finly_transactions.first&.closing_balance&.value&.to_s
    end

    def credit_amount
      self.finly_transactions.credits.sum_amounts || 0
    end

    def debit_amount
      self.finly_transactions.debits.sum_amounts || 0
    end

    def has_transactions_tab?
      self.account.class.name == 'Card'
    end

    def merchant(finly_transaction)
      merchant = ""
      if finly_transaction.credit?
        prefix = 'To '
      else
        prefix = 'From '
      end
      case finly_transaction.payment_purpose_id
        when PaymentPurpose.id_for(:atm_withdrawal)
          merchant = 'ATM withdrawal'
        when PaymentPurpose.id_for(:card_transaction)

        when PaymentPurpose.id_for(:vendor_payment)
          merchant = 'Vendor Payment'
        when PaymentPurpose.id_for(:corporate_balance_load)
          merchant = 'Corporate Balance Load'
        when PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:reimbursement_outside_finly), PaymentPurpose.id_for(:advance), PaymentPurpose.id_for(:balance_clearance),
            PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:medical_benefit), PaymentPurpose.id_for(:meal_benefit), PaymentPurpose.id_for(:payroll), PaymentPurpose.id_for(:balance_clearance_outside_finly)
          merchant = prefix
          if finly_transaction.payment.initiating_account == finly_transaction.finly_account
            if [UserWallet, Card].include? finly_transaction.payment.receiving_account.class
              merchant += "#{finly_transaction.payment.receiving_account.user.name}'s "
            end
            merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.receiving_account)}"
          elsif finly_transaction.payment.receiving_account == finly_transaction.finly_account
            if [UserWallet, Card].include? finly_transaction.payment.initiating_account.class
              merchant += "#{finly_transaction.payment.initiating_account.user.name}'s "
            end
            merchant += "#{AccountManagerUtils.name_for(finly_transaction.payment.initiating_account)}"
          end
      end
      merchant
    end

  end

end
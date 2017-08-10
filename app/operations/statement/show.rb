class Statement::Show < BaseOperation
  attr_accessor :account, :payments, :card_transactions

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
    if params[:with_date_range][:to].blank?
      params[:with_date_range][:to] = Date.today
    end
  end

  def validate
    if self.account.blank?
      add_message :error, 'Account not found'
    end
  end

  def process
    self.payments = Payment.involving_account(self.account)
    if self.account.class.name == 'Card'
      self.card_transactions = self.account.transactions
    end
  end

  def success
    params[:payments] = self.payments
    params[:account] = self.account
    params[:card_transactions] = self.card_transactions
    Statement::Show::SuccessPresenter.new(user, params, messages)
  end

  class Statement::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payments, :account, :card_transactions, :scoped_payments, :scoped_transactions

    has_scope :with_date_range, using: [:from, :to], type: :hash

    def init
      self.account = params[:account]
      self.payments = params[:payments]
      self.scoped_payments = apply_scopes(params[:payments], params)&.paginate(page: params[:page], per_page: 30)
      self.card_transactions = params[:card_transactions]
      if self.card_transactions.present?
        self.scoped_transactions = apply_scopes(self.card_transactions, params)&.paginate(page: params[:page], per_page: 30)
      end
    end

    def credits_count
      return if self.payments.nil? or self.account.nil?
      self.payments.credits_for_account(self.account).count
    end

    def debits_count
      return if self.payments.nil? or self.account.nil?
      self.payments.debits_for_account(self.account).count
    end

    def opening_balance
      opening_payment = self.payments.last
      if opening_payment.initiating_account == self.account
        opening_payment.initiating_account_opening_balance
      else
        opening_payment.receiving_account_opening_balance
      end
    end

    def closing_balance
      closing_payment = self.payments.first
      if closing_payment.initiating_account == self.account
        closing_payment.initiating_account_closing_balance
      else
        closing_payment.receiving_account_closing_balance
      end
    end

    def has_transactions_tab?
      self.account.class.name == 'Card'
    end

    def payment_type(payment)
      if payment.initiating_account == self.account
        payment.credit? ? 'Sent' : 'Received'
      else
        payment.credit? ? 'Received' : 'Sent'
      end
    end

    def purpose(payment)
      payment.purpose.name.humanize
    end

    def merchant(payment)
      if payment.initiating_account == self.account
        if payment.credit?
          "To #{payment.receiving_user.name}'s #{payment.receiving_account.name}"
        else

        end
      else
        if payment.credit?

        else

        end
      end
    end

    def credit(payment)
      if payment.initiating_account == self.account
        payment.debit? ? payment.amount.value : nil
      else
        payment.debit? ? nil : payment.amount.value
      end
    end

    def debit(payment)
      if payment.initiating_account == self.account
        payment.credit? ? payment.amount.value : nil
      else
        payment.credit? ? nil : payment.amount.value
      end
    end

  end

end
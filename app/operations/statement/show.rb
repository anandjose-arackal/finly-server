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
      # when :group
      #   user_presenter = User::Team::Index.(user, params)
      #   unless user_presenter.success?
      #     add_message :error, user_presenter.messages[:error]
      #     return
      #   end
      #   team = user_presenter.team
      #
      # when :team
    end
  end

  def validate
    if self.account.blank?
      add_message :error, 'Account not found'
      return
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
    attr_accessor :payments, :account, :card_transactions

    has_scope :with_date_range, using: [:from, :to], type: :hash

    def init
      self.account = params[:account]
      self.card_transactions = params[:card_transactions]
      self.payments = apply_scopes(params[:payments], params)&.paginate(page: params[:page], per_page: 30)
    end

  end

end
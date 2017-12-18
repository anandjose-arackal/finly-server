class Statements::Team::Summary < Statements::Team::Base
  attr_accessor :columns, :values, :users

  class Statements::Team::Summary::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :values, :categories

    def init
      self.values = params[:values]
      self.categories = user.company.categories
    end

  end

  COLUMNS = %w(
      sl_no
      user
      accounts_net_advance
      accounts_net_reimbursement
      accounts_atm_withdrawals
      accounts_net_opening_balance
      accounts_net_closing_balance
      expense_card_opening_balance
      expense_card_credits
      expense_card_debits
      expense_card_closing_balance
      finly_money_ctc_opening_balance
      finly_money_ctc_credits
      finly_money_ctc_debits
      finly_money_ctc_closing_balance
      finly_money_btc_opening_balance
      finly_money_btc_credits
      finly_money_btc_debits
      finly_money_btc_closing_balance
      cash_on_hand_opening_balance
      cash_on_hand_credits
      cash_on_hand_debits
      cash_on_hand_closing_balance
      reimbursement_card_credits
      expense_category
      expense_card
      expense_cash
      expense_distance
      expense_time
      expense_per_diem
      expense_submitted
      expense_unsubmitted
  )

  def authorized_user_types
    [:company_admin, :finance]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if personal_view? or manager_view?
      add_message :error, 'This is only accessible as a manager or finance manager'
      return
    end
  end

  def init
    self.columns = params[:filter_columns]
    if self.columns.blank?
      self.columns = default_columns
    end
    self.users = User::Index.(user, params).team
  end

  def process
    self.values = []
    self.users.each_with_index do |user, index|
      val = {}
      self.columns.each do |column_name|
        process_column(column_name, user, index)
        val[column_name] = self.process_column(column_name, user, index)
      end
      self.values << val
    end
  end

  def success
    params[:values] = self.values
    Statements::Team::Summary::SuccessPresenter.new(user, params, messages)
  end

  protected
  def default_columns
    %w(
      sl_no
      user
      accounts_net_advance
      accounts_net_reimbursement
      accounts_atm_withdrawals
      accounts_net_opening_balance
      accounts_net_closing_balance
      expense_card_opening_balance
      expense_card_credits
      expense_card_debits
      expense_card_closing_balance
      finly_money_ctc_opening_balance
      finly_money_ctc_credits
      finly_money_ctc_debits
      finly_money_ctc_closing_balance
      finly_money_btc_opening_balance
      finly_money_btc_credits
      finly_money_btc_debits
      finly_money_btc_closing_balance
      cash_on_hand_opening_balance
      cash_on_hand_credits
      cash_on_hand_debits
      cash_on_hand_closing_balance
      reimbursement_card_credits
      expense_card
      expense_cash
      expense_distance
      expense_time
      expense_per_diem
      expense_submitted
      expense_unsubmitted
  )
  end

  def process_column(column_name, user, index)
    case column_name&.to_sym
      when :sl_no
        return index
      when :user
        return {
            name: user.name,
            email: user.email,
            mobile_number: user.mobile_number
        }
      when :accounts_net_advance
        return user.receiving_payments.advance.sum_amounts
      when :accounts_net_reimbursement
        return user.receiving_payments.reimbursement.sum_amounts
      when :accounts_atm_withdrawals
        return user.receiving_payments.atm_withdrawals.sum_amounts
      when :accounts_net_opening_balance
        (dictionary(user, :expense_card, :opening_balance) +
            dictionary(user, :finly_money_ctc, :opening_balance) +
            dictionary(user, :finly_money_btc, :opening_balance) +
            dictionary(user, :cash_on_hand, :opening_balance))
      when :accounts_net_closing_balance
        (dictionary(user, :expense_card, :closing_balance) +
            dictionary(user, :finly_money_ctc, :closing_balance) +
            dictionary(user, :finly_money_btc, :closing_balance) +
            dictionary(user, :cash_on_hand, :closing_balance))
      when :expense_card_opening_balance
        dictionary(user, :expense_card, :opening_balance)
      when :expense_card_credits

      when :expense_card_debits

      when :expense_card_closing_balance
        dictionary(user, :expense_card, :closing_balance)
      when :finly_money_ctc_opening_balance
        dictionary(user, :finly_money_ctc, :opening_balance)
      when :finly_money_ctc_credits

      when :finly_money_ctc_debits

      when :finly_money_ctc_closing_balance
        dictionary(user, :finly_money_ctc, :closing_balance)
      when :finly_money_btc_opening_balance
        dictionary(user, :finly_money_btc, :opening_balance)
      when :finly_money_btc_credits

      when :finly_money_btc_debits

      when :finly_money_btc_closing_balance
        dictionary(user, :finly_money_btc, :closing_balance)
      when :cash_on_hand_opening_balance
        dictionary(user, :cash_on_hand, :opening_balance)
      when :cash_on_hand_credits

      when :cash_on_hand_debits

      when :cash_on_hand_closing_balance
        dictionary(user, :cash_on_hand, :closing_balance)
      when :reimbursement_card_credits

      when :expense_category
        expenses = dictionary user, :expenses, :index
        return expenses.group_by_category_id.sum_amount
      when :expense_card
        expenses = dictionary user, :expenses, :index
        return expenses.only_card_expenses.sum_amount
      when :expense_cash
        expenses = dictionary user, :expenses, :index
        return expenses.only_manual_expenses.sum_amount
      when :expense_distance
        expenses = dictionary user, :expenses, :index
        return expenses.only_distance_expenses.sum_amount
      when :expense_time
        expenses = dictionary user, :expenses, :index
        return expenses.only_time_expenses.sum_amount
      when :expense_per_diem
        expenses = dictionary user, :expenses, :index
        return expenses.only_per_diem_expenses.sum_amount
      when :expense_submitted
        expenses = dictionary user, :expenses, :index
        return expenses.submitted.sum_amount
      when :expense_unsubmitted
        expenses = dictionary user, :expenses, :index
        return expenses.admin_viewable.sum_amount
    end
  end

  ACCOUNT_MAP = {}

  def dictionary(user, account, type)
    return ACCOUNT_MAP&.dig(user)&.dig(account)&.dig(type) if ACCOUNT_MAP&.dig(user)&.dig(account)&.dig(type).present?
    date_from = params&.dig(:filter_date)&.dig(:from) || '2017-01-01'
    date_to = params&.dig(:filter_date)&.dig(:to) || Date.today
    if date_from.class.name == String.name
      date_from = Date.parse date_from
    end
    if date_to.class.name == String.name
      date_to = Date.parse date_to
    end
    unless ACCOUNT_MAP[user].present?
      ACCOUNT_MAP[user] = {}
    end

    case account
      when :expense_card
        unless ACCOUNT_MAP[user][:expense_card]&.dig(:object).present?
          ACCOUNT_MAP[user][:expense_card] = {object: user.cards.expense_cards&.first}
        end
        return 0 unless ACCOUNT_MAP[user][:expense_card]&.dig(:object).present?
        case type
          when :opening_balance
            unless ACCOUNT_MAP[user][:expense_card][:opening_balance].present?
              ACCOUNT_MAP[user][:expense_card][:opening_balance] = ACCOUNT_MAP[user][:expense_card][:object].opening_balance(date_from)
            end
            return ACCOUNT_MAP[user][:expense_card][:opening_balance]
          when :closing_balance
            unless ACCOUNT_MAP[user][:expense_card][:closing_balance].present?
              ACCOUNT_MAP[user][:expense_card][:closing_balance] = ACCOUNT_MAP[user][:expense_card][:object].closing_balance(date_to)
            end
            return ACCOUNT_MAP[user][:expense_card][:closing_balance]
        end
      when :finly_money_btc
        unless ACCOUNT_MAP[user][:finly_money_btc]&.dig(:object).present?
          ACCOUNT_MAP[user][:finly_money_btc] = {object: user.wallet}
        end
        case type
          when :opening_balance
            unless ACCOUNT_MAP[user][:finly_money_btc][:opening_balance].present?
              ACCOUNT_MAP[user][:finly_money_btc][:opening_balance] = ACCOUNT_MAP[user][:finly_money_btc][:object].opening_balance(date_from)
            end
            return ACCOUNT_MAP[user][:finly_money_btc][:opening_balance]
          when :closing_balance
            unless ACCOUNT_MAP[user][:finly_money_btc][:closing_balance].present?
              ACCOUNT_MAP[user][:finly_money_btc][:closing_balance] = ACCOUNT_MAP[user][:finly_money_btc][:object].closing_balance(date_to)
            end
            return ACCOUNT_MAP[user][:finly_money_btc][:closing_balance]
        end
      when :finly_money_ctc
        unless ACCOUNT_MAP[user][:finly_money_ctc]&.dig(:object).present?
          ACCOUNT_MAP[user][:finly_money_ctc] = {object: user.bank_wallet}
        end
        case type
          when :opening_balance
            unless ACCOUNT_MAP[user][:finly_money_ctc][:opening_balance].present?
              ACCOUNT_MAP[user][:finly_money_ctc][:opening_balance] = ACCOUNT_MAP[user][:finly_money_ctc][:object].opening_balance(date_from)
            end
            return ACCOUNT_MAP[user][:finly_money_ctc][:opening_balance]
          when :closing_balance
            unless ACCOUNT_MAP[user][:finly_money_ctc][:closing_balance].present?
              ACCOUNT_MAP[user][:finly_money_ctc][:closing_balance] = ACCOUNT_MAP[user][:finly_money_ctc][:object].closing_balance(date_to)
            end
            return ACCOUNT_MAP[user][:finly_money_ctc][:closing_balance]
        end
      when :cash_on_hand
        unless ACCOUNT_MAP[user][:cash_on_hand]&.dig(:object).present?
          ACCOUNT_MAP[user][:cash_on_hand] = {object: user.cash_on_hand}
        end
        case type
          when :opening_balance
            unless ACCOUNT_MAP[user][:cash_on_hand][:opening_balance].present?
              ACCOUNT_MAP[user][:cash_on_hand][:opening_balance] = ACCOUNT_MAP[user][:cash_on_hand][:object].opening_balance(date_from)
            end
            return ACCOUNT_MAP[user][:cash_on_hand][:opening_balance]
          when :closing_balance
            unless ACCOUNT_MAP[user][:cash_on_hand][:closing_balance].present?
              ACCOUNT_MAP[user][:cash_on_hand][:closing_balance] = ACCOUNT_MAP[user][:cash_on_hand][:object].closing_balance(date_to)
            end
            return ACCOUNT_MAP[user][:cash_on_hand][:closing_balance]
        end
      when :expenses
        unless ACCOUNT_MAP[user][:expenses]&.dig(:object).present?
          ACCOUNT_MAP[user][:expenses] = {object: user.expenses.with_date_range(date_from, date_to)}
        end
        case type
          when :index
            ACCOUNT_MAP[user][:expenses][:object]
        end
    end
  end

end
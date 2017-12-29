class Statements::Team::Summary < Statements::Team::Base
  attr_accessor :columns, :values, :users

  class Statements::Team::Summary::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :columns, :values, :categories

    def init
      self.columns = params[:columns]
      self.values = params[:values]
      self.categories = user.company.categories
    end

    def generate_header_group
      header = []
      self.columns.each do |column|
        if [Hash.name, ActionController::Parameters.name].include? column.class.name
          hash_key = column.keys.first
          name = hash_key.to_s.humanize

          hash_values = column[hash_key]
          span = hash_values.count

          if hash_key&.to_s == 'expense' and hash_values.include? :category
            span += (self.categories.count - 1)
          end

          header << {name: name, span: span}
        else
          header << {name: column.to_s.humanize, span: 1}
        end
      end
      header
    end

    def generate_header_main
      self.columns
      header = []
      self.columns.each do |column|
        if [Hash.name, ActionController::Parameters.name].include? column.class.name
          hash_key = column.keys.first
          hash_values = column[hash_key]
          hash_values.each do |hash_value|
            if hash_key&.to_s == 'expense' and hash_value&.to_s == 'category'
              self.categories.each do |category|
                header << {name: category.name, span: 1}
              end
            else
              header << {name: hash_value.to_s.humanize, span: 1}
            end
          end
        else
          header << {name: column.to_s.humanize, span: 1}
        end
      end
      header
    end

    def generate_contents
      contents = []
      self.values.each do |item|
        user_data = []
        item.each do |key, value|
          if [Hash.name, ActionController::Parameters.name].include? value.class.name
            value.each do |sub_key, sub_value|
              if [Hash.name, ActionController::Parameters.name].include? sub_value.class.name
                self.categories.each do |category|
                  user_data << (sub_value[category.id] || 0)
                end
              else
                user_data << sub_value
              end
            end
          else
            user_data << value
          end
        end
        contents << user_data
      end
      contents
    end

  end

  # COLUMNS = %w(
  #     sl_no
  #     user
  #     accounts_net_advance
  #     accounts_net_reimbursement
  #     accounts_atm_withdrawals
  #     accounts_net_opening_balance
  #     accounts_net_closing_balance
  #     expense_card_opening_balance
  #     expense_card_credits
  #     expense_card_debits
  #     expense_card_closing_balance
  #     finly_money_ctc_opening_balance
  #     finly_money_ctc_credits
  #     finly_money_ctc_debits
  #     finly_money_ctc_closing_balance
  #     finly_money_btc_opening_balance
  #     finly_money_btc_credits
  #     finly_money_btc_debits
  #     finly_money_btc_closing_balance
  #     cash_on_hand_opening_balance
  #     cash_on_hand_credits
  #     cash_on_hand_debits
  #     cash_on_hand_closing_balance
  #     reimbursement_card_credits
  #     expense_category
  #     expense_card
  #     expense_cash
  #     expense_distance
  #     expense_time
  #     expense_per_diem
  #     expense_submitted
  #     expense_unsubmitted
  # )

  COLUMNS = [
      :sl_no,
      {user: [
          :name,
          :email,
          :mobile_number
      ]},
      {accounts: [
          :net_advance,
          :net_reimbursement,
          :atm_withdrawals,
          :net_opening_balance,
          :net_closing_balance
      ]},
      {expense_card: [
          :opening_balance,
          :credits,
          :debits,
          :closing_balance
      ]},
      {finly_money_ctc: [
          :opening_balance,
          :credits,
          :debits,
          :closing_balance
      ]},
      {finly_money_btc: [
          :opening_balance,
          :credits,
          :debits,
          :closing_balance
      ]},
      {cash_on_hand: [
          :opening_balance,
          :credits,
          :debits,
          :closing_balance
      ]},
      {reimbursement_card: [
          :credits
      ]},
      {expense: [
          :category,
          :card,
          :cash,
          :distance,
          :time,
          :per_diem,
          :submitted,
          :unsubmitted
      ]}
  ]


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
    self.users = self.users&.paginate(page: params[:page], per_page: 30)
  end

  def process
    self.values = []
    self.users.each_with_index do |user, index|
      val = {}
      self.columns.each do |key|
        if key.class.name == Hash.name
          hash_key = key.keys.first
          val[hash_key] = {}
          key.values.first.each do |sub_key|
            column_name = "#{hash_key}_#{sub_key}"
            val[hash_key][sub_key] = self.process_column(column_name, user, index)
          end
        else
          val[key] = {}
          val[key] = self.process_column(key, user, index)
        end
      end
      self.values << val
    end
  end

  def success
    params[:columns] = self.columns
    params[:values] = self.values
    Statements::Team::Summary::SuccessPresenter.new(user, params, messages)
  end

  protected
  def default_columns
    [
        :sl_no,
        {user: [
            :name,
            :email,
            :mobile_number
        ]},
        {accounts: [
            :net_advance,
            :net_reimbursement,
            :atm_withdrawals,
            :net_opening_balance,
            :net_closing_balance
        ]},
        {expense_card: [
            :opening_balance,
            :credits,
            :debits,
            :closing_balance
        ]},
        {finly_money_ctc: [
            :opening_balance,
            :credits,
            :debits,
            :closing_balance
        ]},
        {finly_money_btc: [
            :opening_balance,
            :credits,
            :debits,
            :closing_balance
        ]},
        {cash_on_hand: [
            :opening_balance,
            :credits,
            :debits,
            :closing_balance
        ]},
        {reimbursement_card: [
            :credits
        ]},
        {expense: [
            :category,
            :card,
            :cash,
            :distance,
            :time,
            :per_diem,
            :submitted,
            :unsubmitted
        ]}
    ]
  end

  def process_column(column_name, user, index)
    case column_name&.to_sym
      when :sl_no
        return index
      when :user_name
        return user.name
      when :user_email
        return user.email
      when :user_mobile_number
        return user.mobile_number
      when :accounts_net_advance
        return user.receiving_payments.advance.sum_amounts
      when :accounts_net_reimbursement
        return user.receiving_payments.reimbursement.sum_amounts
      when :accounts_atm_withdrawals
        return user.receiving_payments.atm_withdrawals.sum_amounts
      when :accounts_net_opening_balance
        card_opening_balance = dictionary(user, :expense_card, :opening_balance) || 0
        (card_opening_balance +
            dictionary(user, :finly_money_ctc, :opening_balance) +
            dictionary(user, :finly_money_btc, :opening_balance) +
            dictionary(user, :cash_on_hand, :opening_balance))
      when :accounts_net_closing_balance
        card_closing_balance = dictionary(user, :expense_card, :closing_balance) || 0
        (card_closing_balance +
            dictionary(user, :finly_money_ctc, :closing_balance) +
            dictionary(user, :finly_money_btc, :closing_balance) +
            dictionary(user, :cash_on_hand, :closing_balance))
      when :expense_card_opening_balance
        dictionary(user, :expense_card, :opening_balance)
      when :expense_card_credits
        transactions = dictionary(user, :expense_card, :finly_transactions)
        return transactions&.credits&.success&.sum_amounts || 0
      when :expense_card_debits
        transactions = dictionary(user, :expense_card, :finly_transactions)
        return transactions&.debits&.success&.sum_amounts || 0
      when :expense_card_closing_balance
        dictionary(user, :expense_card, :closing_balance)
      when :finly_money_ctc_opening_balance
        dictionary(user, :finly_money_ctc, :opening_balance)
      when :finly_money_ctc_credits
        transactions = dictionary(user, :finly_money_ctc, :finly_transactions)
        return transactions&.credits&.success&.sum_amounts || 0
      when :finly_money_ctc_debits
        transactions = dictionary(user, :finly_money_ctc, :finly_transactions)
        return transactions&.debits&.success&.sum_amounts || 0
      when :finly_money_ctc_closing_balance
        dictionary(user, :finly_money_ctc, :closing_balance)
      when :finly_money_btc_opening_balance
        dictionary(user, :finly_money_btc, :opening_balance)
      when :finly_money_btc_credits
        transactions = dictionary(user, :finly_money_btc, :finly_transactions)
        return transactions&.credits&.success&.sum_amounts || 0
      when :finly_money_btc_debits
        transactions = dictionary(user, :finly_money_btc, :finly_transactions)
        return transactions&.debits&.success&.sum_amounts || 0
      when :finly_money_btc_closing_balance
        dictionary(user, :finly_money_btc, :closing_balance)
      when :cash_on_hand_opening_balance
        dictionary(user, :cash_on_hand, :opening_balance)
      when :cash_on_hand_credits
        transactions = dictionary(user, :cash_on_hand, :finly_transactions)
        return transactions&.credits&.success&.sum_amounts || 0
      when :cash_on_hand_debits
        transactions = dictionary(user, :cash_on_hand, :finly_transactions)
        return transactions&.debits&.success&.sum_amounts || 0
      when :cash_on_hand_closing_balance
        dictionary(user, :cash_on_hand, :closing_balance)
      when :reimbursement_card_credits
        transactions = dictionary(user, :reimbursement_card, :finly_transactions)
        return transactions&.credits&.success&.through_finly_dashboard&.sum_amounts || 0
      when :expense_category
        expenses = dictionary user, :expenses, :object
        return expenses.group_by_category_id.sum_amount
      when :expense_card
        expenses = dictionary user, :expenses, :object
        return expenses.only_card_expenses.sum_amount
      when :expense_cash
        expenses = dictionary user, :expenses, :object
        return expenses.only_manual_expenses.sum_amount
      when :expense_distance
        expenses = dictionary user, :expenses, :object
        return expenses.only_distance_expenses.sum_amount
      when :expense_time
        expenses = dictionary user, :expenses, :object
        return expenses.only_time_expenses.sum_amount
      when :expense_per_diem
        expenses = dictionary user, :expenses, :object
        return expenses.only_per_diem_expenses.sum_amount
      when :expense_submitted
        expenses = dictionary user, :expenses, :object
        return expenses.submitted.sum_amount
      when :expense_unsubmitted
        expenses = dictionary user, :expenses, :object
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
        return nil unless ACCOUNT_MAP[user][:expense_card]&.dig(:object).present?
        case type
          when :object
            return ACCOUNT_MAP[user][:expense_card]&.dig(:object)
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
          when :finly_transactions
            unless ACCOUNT_MAP[user][:expense_card][:finly_transactions].present?
              ACCOUNT_MAP[user][:expense_card][:finly_transactions] = ACCOUNT_MAP[user][:expense_card][:object].finly_transactions.with_date_range(date_from, date_to)
            end
            return ACCOUNT_MAP[user][:expense_card][:finly_transactions]
        end
      when :reimbursement_card
        unless ACCOUNT_MAP[user][:reimbursement_card]&.dig(:object).present?
          ACCOUNT_MAP[user][:reimbursement_card] = {object: user.cards.reimbursement_cards&.first}
        end
        return nil unless ACCOUNT_MAP[user][:reimbursement_card]&.dig(:object).present?
        case type
          when :object
            return ACCOUNT_MAP[user][:reimbursement_card]&.dig(:object)
          when :finly_transactions
            unless ACCOUNT_MAP[user][:reimbursement_card][:finly_transactions].present?
              ACCOUNT_MAP[user][:reimbursement_card][:finly_transactions] = ACCOUNT_MAP[user][:reimbursement_card][:object].finly_transactions.with_date_range(date_from, date_to)
            end
            return ACCOUNT_MAP[user][:reimbursement_card][:finly_transactions]
        end
      when :finly_money_btc
        unless ACCOUNT_MAP[user][:finly_money_btc]&.dig(:object).present?
          ACCOUNT_MAP[user][:finly_money_btc] = {object: user.wallet}
        end
        case type
          when :object
            return ACCOUNT_MAP[user][:finly_money_btc]&.dig(:object)
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
          when :finly_transactions
            unless ACCOUNT_MAP[user][:finly_money_btc][:finly_transactions].present?
              ACCOUNT_MAP[user][:finly_money_btc][:finly_transactions] = ACCOUNT_MAP[user][:finly_money_btc][:object].finly_transactions.with_date_range(date_from, date_to)
            end
            return ACCOUNT_MAP[user][:finly_money_btc][:finly_transactions]
        end
      when :finly_money_ctc
        unless ACCOUNT_MAP[user][:finly_money_ctc]&.dig(:object).present?
          ACCOUNT_MAP[user][:finly_money_ctc] = {object: user.bank_wallet}
        end
        case type
          when :object
            return ACCOUNT_MAP[user][:finly_money_ctc]&.dig(:object)
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
          when :finly_transactions
            unless ACCOUNT_MAP[user][:finly_money_ctc][:finly_transactions].present?
              ACCOUNT_MAP[user][:finly_money_ctc][:finly_transactions] = ACCOUNT_MAP[user][:finly_money_ctc][:object].finly_transactions.with_date_range(date_from, date_to)
            end
            return ACCOUNT_MAP[user][:finly_money_ctc][:finly_transactions]
        end
      when :cash_on_hand
        unless ACCOUNT_MAP[user][:cash_on_hand]&.dig(:object).present?
          ACCOUNT_MAP[user][:cash_on_hand] = {object: user.cash_on_hand}
        end
        case type
          when :object
            return ACCOUNT_MAP[user][:cash_on_hand]&.dig(:object)
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
          when :finly_transactions
            unless ACCOUNT_MAP[user][:cash_on_hand][:finly_transactions].present?
              ACCOUNT_MAP[user][:cash_on_hand][:finly_transactions] = ACCOUNT_MAP[user][:cash_on_hand][:object].finly_transactions.with_date_range(date_from, date_to)
            end
            return ACCOUNT_MAP[user][:cash_on_hand][:finly_transactions]
        end
      when :expenses
        unless ACCOUNT_MAP[user][:expenses]&.dig(:object).present?
          ACCOUNT_MAP[user][:expenses] = {object: user.expenses.with_date_range(date_from, date_to)}
        end
        case type
          when :object
            ACCOUNT_MAP[user][:expenses][:object]
        end
    end
  end

end
class Statements::Team::Summary < Statements::Team::Base
  attr_accessor :columns, :values, :users

  COLUMNS = %w(
      sl_no
      user
      accounts_net_advance
      accounts_net_reimbursement
      accounts_atm_withdrawals
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
        val[column_name] = self.send("process_#{column_name}", user, index)
      end
    end
  end

  protected
  def default_columns
    %w(
      sl_no
      user
      accounts_net_advance
      accounts_net_reimbursement
      accounts_atm_withdrawals
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
        return user.receiving_payments.reimbursements.sum_amounts
      when :accounts_atm_withdrawals

      when :accounts_net_closing_balance
      when :expense_card_opening_balance
      when :expense_card_credits
      when :expense_card_debits
      when :expense_card_closing_balance
      when :finly_money_ctc_opening_balance
      when :finly_money_ctc_credits
      when :finly_money_ctc_debits
      when :finly_money_ctc_closing_balance
      when :finly_money_btc_opening_balance
      when :finly_money_btc_credits
      when :finly_money_btc_debits
      when :finly_money_btc_closing_balance
      when :cash_on_hand_opening_balance
      when :cash_on_hand_credits
      when :cash_on_hand_debits
      when :cash_on_hand_closing_balance
      when :reimbursement_card_credits
      when :expense_category
      when :expense_card
      when :expense_cash
      when :expense_distance
      when :expense_time
      when :expense_per_diem
    end
  end

  ACCOUNT_MAP = {}

  def account_amount(user, account, type)

  end

end
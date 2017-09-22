module Accountable
  extend ActiveSupport::Concern

  def opening_balance(date)
    return 0 if date.blank?
    date = date.beginning_of_day
    balance = finly_transactions.before_date(date).limit_to_one&.first&.closing_balance&.value
    return balance unless balance.nil?

    # todo Jugaad to access historical data
    from = (date - 1.day)
    case self.account.class.name
      when Card.name
        self.user.user_balance_histories.with_date(from)&.first&.card_balance&.value || 0
      when ItzCashCompanyAccount.name
        self.company.company_balance_histories.with_date(from)&.first&.company_balance&.value || 0
      when UserWallet.name
        self.user.user_balance_histories.with_date(from)&.first&.finly_money_balance&.value || 0
      when CashOnHand.name
        self.user.user_balance_histories.with_date(from)&.first&.cash_on_hand_balance&.value || 0
    end
  end

  def closing_balance(date)
    return 0 if date.blank?
    date = date + 1
    date = date.beginning_of_day
    balance = finly_transactions.before_date(date).limit_to_one&.first&.closing_balance&.value
    return balance unless balance.nil?

    # todo Jugaad to access historical data
    to = date
    case self.account.class.name
      when Card.name
        self.user.user_balance_histories.with_date(to)&.first&.card_balance&.value || 0
      when ItzCashCompanyAccount.name
        self.company.company_balance_histories.with_date(to)&.first&.company_balance&.value || 0
      when UserWallet.name
        self.user.user_balance_histories.with_date(to)&.first&.finly_money_balance&.value || 0
      when CashOnHand.name
        self.user.user_balance_histories.with_date(to)&.first&.cash_on_hand_balance&.value || 0
    end
  end

end
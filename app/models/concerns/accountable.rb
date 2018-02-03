module Accountable
  extend ActiveSupport::Concern

  included do
    has_one :virtual_bank_account, as: :parent, class_name: 'VirtualBankAccount', dependent: :destroy
  end

  def va_config
    {
        enabled: false,
        purpose_id: nil,
        options: {},
        company: nil,
        application: nil
    }
  end

  def va_generate
    config = va_config
    enabled = config[:enabled]
    purpose_id = config[:purpose_id]
    company = config[:company]
    application = config[:application]
    if enabled and self.virtual_bank_account.blank? and purpose_id.present? and application.present? and company.present?
      ::Invoicing::VirtualBankAccount::Create.(nil, {application: application, company: company, parent: self, purpose_id: purpose_id, receiving_account: self})
    end
  end

  def opening_balance(date)
    return 0 if date.blank?
    date = date.beginning_of_day
    balance = finly_transactions.before_date(date).limit_to_one&.first&.closing_balance&.value
    return balance unless balance.nil?

    # todo Jugaad to access historical data
    from = (date - 1.day)
    case self.class.name
      when Card.name
        return self.user.user_balance_histories.with_date(from)&.first&.card_balance&.value || 0
      when ItzCashCompanyAccount.name
        return self.company.company_balance_histories.with_date(from)&.first&.company_balance&.value || 0
      when UserWallet.name
        return self.user.user_balance_histories.with_date(from)&.first&.finly_money_balance&.value || 0
      when CashOnHand.name
        return self.user.user_balance_histories.with_date(from)&.first&.cash_on_hand_balance&.value || 0
      when YesBankCompanyAccount.name
        return 0
    end
    return 0
  end

  def closing_balance(date)
    return 0 if date.blank?
    date = date + 1
    date = date.beginning_of_day
    balance = finly_transactions.before_date(date).limit_to_one&.first&.closing_balance&.value
    return balance unless balance.nil?

    # todo Jugaad to access historical data
    to = date
    case self.class.name
      when Card.name
        return self.user.user_balance_histories.with_date(to)&.first&.card_balance&.value || 0
      when ItzCashCompanyAccount.name
        return self.company.company_balance_histories.with_date(to)&.first&.company_balance&.value || 0
      when UserWallet.name
        return self.user.user_balance_histories.with_date(to)&.first&.finly_money_balance&.value || 0
      when CashOnHand.name
        return self.user.user_balance_histories.with_date(to)&.first&.cash_on_hand_balance&.value || 0
      when YesBankCompanyAccount.name
        return 0
    end
    return 0
  end

end
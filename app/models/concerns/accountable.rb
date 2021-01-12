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
    # balance = finly_transactions.before_date(date).limit_to_one&.first&.closing_balance&.value

    # As company balance load's do not have opening or closing balance, this is to handle cases which do not have opening or closing balance
    # In case opening balance is required where company balance load was the first transaction performed, then fetch the previous day's last transactions closing balance as the day's closing balance
    binding.pry
    transaction = finly_transactions.on_or_after_date(date)&.order(:sequence_number)&.limit_to_one&.first
    if transaction&.opening_balance_id.present?
      balance = transaction&.opening_balance&.value
    else
      balance = finly_transactions.before_date(date)&.order(sequence_number: :desc)&.limit_to_one&.first&.closing_balance&.value
    end
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
    # date = date + 1
    date = date.end_of_day
    # balance = finly_transactions.on_or_before_date(date)&.sort_date_desc&.limit_to_one&.first&.closing_balance&.value

    # As company balance load's do not have opening or closing balance, this is to handle cases which do not have opening or closing balance
    # In case opening balance is required where company balance load was the last transaction performed, then fetch the next day's first transactions opening balance as the day's closing balance
    transaction = finly_transactions.on_or_before_date(date)&.order(sequence_number: :desc)&.limit_to_one&.first
    if transaction&.closing_balance_id.present?
      balance = transaction&.closing_balance&.value
    else
      balance = finly_transactions.after_date(date)&.order(:sequence_number)&.limit_to_one&.first&.opening_balance&.value
    end

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
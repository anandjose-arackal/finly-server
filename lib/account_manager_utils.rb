class AccountManagerUtils

  ACCOUNTS = [
      {class: Card, name: 'Card', code: 'CRD'},
      {class: UserWallet, name: 'Finly Money', code: 'FMY'},
      {class: ItzCashCompanyAccount, name: 'Company Credits', code: 'ITA'},
      {class: YesBankCompanyAccount, name: 'Bank Transfer Credits', code: 'YBA'},
      {class: CashOnHand, name: 'Cash on Hand', code: 'COH'},
      {class: BankAccount, name: 'Bank Account', code: 'BAC'},
  ]

  def self.available_accounts(options = {})
    options = {} if options.nil?
    options[:format] = :class if options[:format].blank?
    classes = []
    ACCOUNTS.each do |account|
      case options[:format]
        when :class
          classes << account[:class]
        when :string
          classes << account[:class].to_s
      end
    end
    classes
  end

  def self.name_for(account)
    return nil if account.blank?
    if account.is_a?(Class)
      # Class is being passed
      class_string = account.name
    elsif account.class.name == 'String'
      # Account type being passed
      class_string = account
    else
      # Object
      class_string = account.class.name
    end
    account_name = nil
    ACCOUNTS.each do |account|
      if account[:class].to_s == class_string
        account_name = account[:name]
        break
      end
    end
    if account_name == 'Card' and self.account.class.name == Card.name
      account_name = "#{account.card_program.name.humanize} Card"
    end
    account_name
  end

  def self.code_for(account)
    return nil if account.blank?
    if account.is_a?(Class)
      # Class is being passed
      class_string = account.name
    elsif account.class.name == 'String'
      # Account type being passed
      class_string = account
    else
      # Object
      class_string = account.class.name
    end
    account_name = nil
    ACCOUNTS.each do |account|
      if account[:class].to_s == class_string
        account_name = account[:code]
        break
      end
    end
    account_name
  end

end
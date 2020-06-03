class AccountManagerUtils

  ACCOUNTS = [
      {class: Card, name: 'Card', code: 'CRD'},
      {class: UserWallet, name: 'Finly Money', code: 'FMY'},
      {class: VendorPaymentWallet, name: 'Finly Money ( Bank Transfer )', code: 'FMB'},
      {class: ItzCashCompanyAccount, name: 'Company Credits', code: 'ITA'},
      {class: YesBankCompanyAccount, name: 'Bank Transfer Credits', code: 'YBA'},
      {class: CashOnHand, name: 'Cash on Hand', code: 'COH'},
      {class: BankAccount, name: 'Bank Account', code: 'BAC'},
      {class: UserPocket, name: "User Pocket", code: "USP"},
      {class: KotakBankCompanyAccount, name: 'Kotak Bank Account Credits', code: 'KBA'},
      {class: IciciBankCompanyAccount, name: 'Icici Bank Account Credits', code: 'IBA'},
      {class: UtilityBillsAccount, name: 'Utility Bills Account Credits', code: 'UBA'},
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
    ACCOUNTS.each do |finly_account|
      if finly_account[:class].to_s == class_string
        account_owner = nil
        if account.is_a?(Object)
          case account.class.name
            when UserWallet.name, VendorPaymentWallet.name, CashOnHand.name, Card.name, UserPocket.name
              account_owner = account.user.name
            when BankAccount.name
               account_owner = account.account_owner.name
            else
              account_owner = nil
          end
        end
        if account_owner.present?
          account_name = "#{account_owner.to_s}'s " + finly_account[:name]
        else
          account_name = finly_account[:name]
        end
        break
      end
    end
    if account_name == 'Card' and account.class.name == Card.name
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
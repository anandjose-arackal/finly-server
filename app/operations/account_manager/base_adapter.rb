class AccountManager::BaseAdapter

  attr_accessor :errors, :account

  def initialize(account=nil)
    # source is the source from where the credit / debit is supposed to happen
    # params is general, can be anything
    self.errors = []
    if account_class.present? and account.nil?
      raise 'Account cannot be blank'
    end
    if account.class.name != name
      raise 'Account mismatch. Incorrect adapter'
    end
    self.account = account
  end

  def account_class

  end

  def name
    self.account_class&.name
  end

  def credit(payment)
    self.errors = []
  end

  def debit(payment)
    self.errors = []
  end

  def balance(payment)
    self.errors = []
  end

  def eligibility(payment)
    self.errors = []
  end

  def creditable_accounts

  end

  def debitable_accounts

  end

  def creditable_account?(account_type)
    if account_type.present? and not account_type.is_a?(String)
      account_type = account_type&.class.name
    end
    creditable_accounts = self.creditable_accounts
    return false if creditable_accounts.nil?
    creditable_accounts.each { |account| return true if account_type == account&.to_s }
    false
  end

  def debitable_account?(account_type)
    if account_type.present? and not account_type.is_a?(String)
      account_type = account_type&.class.name
    end
    debitable_accounts = self.debitable_accounts
    return false if debitable_accounts.nil?
    debitable_accounts.each { |account| return true if account_type == account&.to_s }
    false
  end

  def valid?
    self.errors.blank?
  end

end
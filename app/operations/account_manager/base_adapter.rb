class AccountManager::BaseAdapter
  attr_accessor :errors, :account

  def initialize(account=nil, payment = nil)
    # source is the source from where the credit / debit is supposed to happen
    # params is general, can be anything
    self.errors = []
    if account_class.present? and account.nil?
      raise 'Account cannot be blank'
    end
    unless account_class.name == account.class.name
      raise 'Account mismatch. Incorrect adapter'
    end
    self.account = account
  end

  def account_class

  end

  def name
    AccountManagerUtils.name_for ((self.account || self.account_class))
  end

  def credit(payment, options = {})
    self.errors = []
  end

  def debit(payment, options = {})
    self.errors = []
  end

  def balance(payment)
    self.errors = []
  end

  def eligibility(payment)
    self.errors = []
  end

  # i.e. accounts from which we can credit a particular account
  def creditable_accounts

  end

  # i.e. accounts to which we can debit a particular account
  def debitable_accounts

  end

  def on_completion(options)

  end

  def on_failure(options)

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

  def accept_va_transaction?
    false
  end

  def on_va_transaction(payment, options={})
    self.errors = []
  end

  def store_transaction(payment, type, status, opening_balance, closing_balance, company_id, system_messages = {})
    type_id = TransactionType.id_for(type)
    status_id = TransactionStatus.id_for(status)
    currency_id = Currency.id_for(:INR)
    params = {
        transaction_type_id: type_id,
        status_id: status_id,
        amount_attributes: {
            value: payment.amount_value,
            currency_id: currency_id
        },
        payment_purpose_id: payment.payment_purpose_id,
        opening_balance_attributes: {
            value: opening_balance,
            currency_id: currency_id
        },
        closing_balance_attributes: {
            value: closing_balance,
            currency_id: currency_id
        },
        associated_transaction: payment.reference_resource,
        payment: payment,
        company_id: company_id,
        date: DateTime.now
    }
    transaction = self.account.finly_transactions.create params
    if system_messages.present?
      # Setting system messages
      errors = system_messages[:error].to_a + system_messages[:failure].to_a
      success = system_messages[:success].to_a
      info = system_messages[:message].to_a + system_messages[:notice].to_a
      errors.each do |error_message|
        transaction.system_messages.create system_message_type_id: SystemMessageType.id_for(:error), content: error_message
      end
      success.each do |success_message|
        transaction.system_messages.create system_message_type_id: SystemMessageType.id_for(:success), content: success_message
      end
      info.each do |info_message|
        transaction.system_messages.create system_message_type_id: SystemMessageType.id_for(:info), content: info_message
      end
    end
  end

end
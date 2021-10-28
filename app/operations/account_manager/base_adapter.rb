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
    # debugger
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
        associated_transaction: payment.reference_resources.first,
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

  def execute_callback(payment)
    post_params = {
        payment_id: payment.id,
        external_reference_id: payment.external_reference_id,
        payment_amount: payment.amount_value,
        note: payment.note,
        status: payment.payment_status&.name,
        receiving_account: {
            receiving_account_type: "BankAccount",
            receiving_account_id: payment.receiving_account&.id,
            receiving_account_number: payment.receiving_account&.account_number,
            receiving_account_ifsc: payment.receiving_account&.ifsc
        },
        bank_reference_number: payment.utr
    }
    if payment.failed?
      post_params[:errors] = payment.system_messages.errors.pluck(:content).to_sentence
    end
    # this particular type of payment will always have an initiating user because it is a vendor payment / reimbursement payment
    company = payment.initiating_user&.company
    op = Webhook::Process.(nil, {company: company, body: post_params, web_hook_event_id: WebHookEvent.id_for('vendor_payments.credit_confirmation')})
    if company.web_hooks.present?
      callback_track = CallbackTrack.new(company: company, entity: payment, request: post_params.to_s)
      if op.success?
        callback_track.update(success: true, response: (op.body rescue nil))
      else
        callback_track.update(success: false, response: (op.body rescue nil))
      end
    end
  end

end
class AccountManager::Collect::CollectRouter < AccountManager::Collect::Base
  sidekiq_options queue: :payments_queue

  attr_accessor :virtual_account_transaction, :virtual_account

  def init
    t_params = transaction_params
    transfer_id = t_params[:transfer_id]
    self.virtual_account_transaction = VirtualAccountTransaction.with_transfer_id(transfer_id)&.first
    if virtual_account_transaction.blank?
      self.virtual_account_transaction = VirtualAccountTransaction.new transaction_params
      self.virtual_account = ::VirtualBankAccount.find_by(account_number: virtual_account_transaction.beneficiary_account_no)
      self.virtual_account_transaction.virtual_account = self.virtual_account
    else
      self.virtual_account = self.virtual_account_transaction.virtual_account
    end
  end

  def validate
    unless self.virtual_account
      self.virtual_account_transaction.log_state(:error, 'Virtual Account not found')
      add_message :error, 'Virtual Account not found'
      Event::EAlert::Create.(nil, title: 'Finly Collect - Account not found',description: "#{self.virtual_account_transaction.as_json}", subject: 'Finly Collect - Account not found')
      return
    end
    if self.virtual_account_transaction.processed
      self.virtual_account_transaction.log_state(:error, 'Transaction has already been processed')
      add_message :error, 'Transaction has already been processed'
      Event::EAlert::Create.(nil, title: 'Finly Collect - Transaction already processed',description: "#{self.virtual_account_transaction.as_json}", subject: 'Finly Collect - Transaction already processed')
      return
    end
  end

  def process
    unless self.virtual_account_transaction.save
      self.virtual_account_transaction.log_state :error, self.virtual_account_transaction.errors.full_messages
      add_message :error, self.virtual_account_transaction.errors.full_messages
      Event::EAlert::Create.(nil, title: 'Finly Collect - Transaction Save Failed',description: "#{self.virtual_account_transaction.as_json}<br><br>Errors: #{self.virtual_account_transaction.errors.full_messages.as_json}", subject: 'Finly Collect - Transaction already processed')
    end
  end

  def post_process
    # AccountManager::Collect::VATransactionProcessor.call(user, virtual_account_transaction_id: virtual_account_transaction.id)
    AccountManager::Collect::VATransactionProcessor.call_async(user, virtual_account_transaction_id: virtual_account_transaction.id)
  end

  private

  def transaction_params
    params&.permit(
        :beneficiary_account_no,
        :beneficiary_account_ifsc,
        :transfer_type,
        :beneficiary_full_name,
        :transfer_id,
        :transfer_timestamp,
        :transfer_currency,
        :transfer_amount,
        :remitter_account_no,
        :remitter_account_ifsc,
        :remitter_account_type,
        :remitter_full_name,
        :remitter_address,
        :note,
        :credited_at
    )
  end
end
class AccountManager::Collect::VATransactionProcessor < BackgroundOperation
  attr_accessor :virtual_account_transaction, :virtual_account, :payment, :adapter

  def pre_validate
    unless params[:virtual_account_transaction_id].present?
      add_message :error, 'Virtual Account Transaction not found'
      return
    end
  end

  def init
    self.virtual_account_transaction = VirtualAccountTransaction.find_by_id(params[:virtual_account_transaction_id])
    self.virtual_account = self.virtual_account_transaction&.virtual_account
    self.virtual_account_transaction.log_state(:info, 'Initiated Processing')
    self.adapter = adapter_for self.virtual_account
  end

  def validate
    if self.virtual_account.blank?
      add_message :error, 'Virtual Account not found'
      return
    end
    if self.virtual_account_transaction.processed
      self.virtual_account_transaction.log_state(:error, 'Virtual Account has already been processed')
      add_message :error, 'Virtual Account has already been processed'
      return
    end
    if self.adapter.blank?
      self.virtual_account_transaction.log_state(:error, 'Adapter not found')
      add_message :error, 'Adapter not found'
      return
    end
    unless adapter.accept_va_transaction?
      self.virtual_account_transaction.log_state(:error, 'Account cannot accept VA Transactions')
      add_message :error, 'Account cannot accept VA Transactions'
      return
    end
  end

  def process

  end

  protected
  def adapter_for(virtual_account)
    case virtual_account.receiving_account_type
      when YesBankCompanyAccount.name
        return YesBankCompanyAccountAdapter.new virtual_account.receiving_account
      when VendorPaymentWallet.name
        return VendorPaymentWalletAdapter.new virtual_account.receiving_account
      when CashOnHand.name
        return CashOnHandAdapter.new virtual_account.receiving_account
    end
  end

end
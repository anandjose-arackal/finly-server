class AccountManager::Collect::VATransactionProcessor < BackgroundOperation
  queue_as :payments_queue

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
    build_payment
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
    credit_account
    return if has_errors?
    case self.virtual_account.purpose_id
      when VirtualAccountPurpose.id_for(:payment_receivable)
        AccountManager::Collect::PaymentReceivable::Accept.(nil, virtual_account_transaction: self.virtual_account_transaction)
      when VirtualAccountPurpose.id_for(:invoice)
        # this will take the respective payment for the invoice and mark it as paid or partially paid accordingly
        op = AccountManager::Collect::Invoice::Accept.(nil, virtual_account_transaction: self.virtual_account_transaction)
        # if this operation isn't successful, update the virtual account transaction as not reconciled
        unless op.success?
          self.virtual_account_transaction.update(processed: false)
          self.virtual_account_transaction.log_state(:error, 'Invoice payment not reconciled')
        end
      else
        # do nothing?
    end
  end

  def post_process
    self.virtual_account_transaction.update(processed: true)
    self.virtual_account_transaction.log_state(:info, 'Processed')

    # trigger the api call for Webhooks
    # setting the body of the webhook
    body = {
      "beneficiary_account_no": self.virtual_account.account_number,
      "beneficiary_account_ifsc": self.virtual_account.ifsc,
      "beneficiary_full_name": self.virtual_account.company.name,
      "transfer_type": self.virtual_account_transaction.transfer_type,
      "transfer_id": self.virtual_account_transaction.transfer_id,
      "transfer_timestamp": self.virtual_account_transaction.transfer_timestamp,
      "transfer_currency": self.virtual_account_transaction.transfer_currency,
      "transfer_amount": self.virtual_account_transaction.transfer_amount,
      "remitter_account_no": self.virtual_account_transaction.remitter_account_no,
      "remitter_account_ifsc": self.virtual_account_transaction.remitter_account_ifsc,
      "remitter_account_type": self.virtual_account_transaction.remitter_account_type,
      "remitter_full_name": self.virtual_account_transaction.remitter_full_name,
      "remitter_address": self.virtual_account_transaction.remitter_address,
      "note": self.virtual_account_transaction.note,
      "transfer_status": "CREDITED",
      "credited_at": self.virtual_account_transaction.credited_at,
      "returned_at": nil,
      "attempt_no": 1,
      "reject_reason": nil
    }
    op = Webhook::Process.(nil, {company: self.virtual_account.company, body: body, web_hook_event_id: WebHookEvent.id_for('collect.transaction')})
  end

  protected
  def adapter_for(virtual_account)
    case virtual_account&.receiving_account_type
      when YesBankCompanyAccount.name
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new virtual_account.receiving_account
      when VendorPaymentWallet.name
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new virtual_account.receiving_account
      when CashOnHand.name
        return AccountManager::CashOnHand::CashOnHandAdapter.new virtual_account.receiving_account
    end
  end

  def build_payment
    self.payment = self.virtual_account_transaction.build_payment(
        payment_type_id: PaymentType.id_for(:credit),
        application: self.virtual_account&.application,
        initiating_account: self.virtual_account,
        receiving_account: self.adapter.account,
        payment_status_id: PaymentStatus.id_for(:pending),
        payment_purpose_id: self.virtual_account.purpose.payment_purpose_id,
        payment_mode: self.virtual_account_transaction&.transfer_type,
        amount_attributes: {
            value: self.virtual_account_transaction&.transfer_amount,
            currency_id: Currency.id_for(:INR)
        },
        date: self.virtual_account_transaction&.transfer_timestamp,
        reference_resource: self.virtual_account_transaction,
        note: self.virtual_account_transaction&.note
    )
    self.payment.save
  end

  def credit_account
    if self.virtual_account_transaction.receiving_account_credited
      self.virtual_account_transaction.log_state(:info, 'Receiving Account has already been credited')
      return
    end
    if self.adapter.on_va_transaction(self.payment)
      self.virtual_account_transaction.log_state(:info, "#{self.adapter.account.class.name} Credited")
      self.virtual_account_transaction.update(receiving_account_credited: true)
      self.payment.update(payment_status_id: PaymentStatus.id_for(:completed))
    else
      self.virtual_account_transaction.log_state(:error, 'Payment Credit Failed')
      add_message :error, 'Error processing payment'
      self.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
    end
  end

end
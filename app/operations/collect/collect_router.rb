# this is the class that will route the virtual transaction object to the appropriate one based on purpose
# it will accept the parameters of the request an=nd store them in the
class Collect::CollectRouter < BaseOperation

  attr_accessor :virtual_account_transaction_params, :virtual_account_transaction, :purpose_id,
                :virtual_account

  def init
    self.virtual_account_transaction_params = transaction_params
    self.virtual_account = VirtualBankAccount.find_by(account_number: virtual_account_transaction_params[:beneficiary_account_number])
    unless self.virtual_account.blank?
      self.purpose_id = virtual_account.purpose.id
    end
  end

  def validate
    if self.virtual_account.blank?
      add_message :error, "Virtual Account not found"
    end
  end

  def process
    self.virtual_account_transaction = VirtualAccountTransaction.new(self.virtual_account_transaction_params)
    if self.virtual_account_transaction.save
      # trigger the respective background operation that will execute the payment
      case self.purpose_id
        when VirtualAccountPurpose.id_for(:virtual_bank_account)
          Invoicing::VirtualBankAccount::Accept.call_async(virtual_account_transaction_id: self.virtual_account_transaction.id)
        when VirtualAccountPurpose.id_for(:payment_receivable)
          Invoicing::PaymentReceivable::Accept.call_async(virtual_account_transaction_id: self.virtual_account_transaction.id)
        when VirtualAccountPurpose.id_for(:invoice)
          Invoicing::Invoice::Accept.call_async(virtual_account_transaction_id: self.virtual_account_transaction.id)
        else
          # do nothing?
      end
    end
  end

  def post_process

  end

  private

  def transaction_params
    params&.permit(:beneficiary_account_number,
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
                   :credited_at)
  end

end
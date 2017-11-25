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

  def pre_process
    self.virtual_account_transaction_params[:virtual_account_id] = self.virtual_account.id
  end

  def process
    self.virtual_account_transaction = VirtualAccountTransaction.new(self.virtual_account_transaction_params)
    if self.virtual_account_transaction.save
      # trigger the respective background operation that will execute the payment
      # todo - change all the below ones to async calls after testing
      case self.purpose_id
        when VirtualAccountPurpose.id_for(:virtual_bank_account)
          op = Collect::VirtualAccount::Accept.(self.virtual_account_transaction.id)
        when VirtualAccountPurpose.id_for(:payment_receivable)
          Collect::PaymentReceivable::Accept.(self.virtual_account_transaction.id)
        when VirtualAccountPurpose.id_for(:invoice)
          Collect::Invoice::Accept.(self.virtual_account_transaction.id)
        when VirtualAccountPurpose.id_for(:corporate_balance_reload)
          Collect::CorporateBalanceReload::BalanceReload.(self.virtual_account_transaction.id)
        when VirtualAccountPurpose.id_for(:cash_on_hand_reversal)
          Collect::CashOnHandReturn::Return.(self.virtual_account_transaction.id)
        else
          # do nothing?
      end
    else
      add_message :error, virtual_account_transaction.errors.full_messages
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
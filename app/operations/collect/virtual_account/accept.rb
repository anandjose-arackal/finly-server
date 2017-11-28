# this would create a payment request that can handle

class Collect::VirtualAccount::Accept < Collect::VirtualAccount::Base

  attr_accessor :virtual_account, :company, :virtual_account_transaction,
                :payment_request

  def init
    id = params[:id] || params[:virtual_account_transaction_id]
    self.virtual_account_transaction = ::VirtualAccountTransaction.find_by(id: id)
    self.virtual_account = self.virtual_account_transaction.virtual_account
    self.company = virtual_account.company
    self.payment_request = init_payment_request(:virtual_bank_account, virtual_account.receiving_account)
  end

  def validate
    if self.virtual_account.blank?
      add_message :error, "Virtual bank account number not found"
    end
  end

  def process
    # triggering the operation for creating the payment
    # and marks the respective payment against
    op = AccountManager::Payments::PaymentProcessor.(self.virtual_account.initiating_user, payment_request: self.payment_request)
    if op.success?
      payment = op.payment_order&.payments.first
      payment.update(reference_resource: self.virtual_account_transaction)
    end
  end

  def post_process
    # trigger mailers if necessary
  end
end
# this would create a payment request that can handle

class Collect::VirtualAccount::Accept < Collect::VirtualAccount::Base

  attr_accessor :virtual_account, :company, :virtual_account_transaction,
                :payment_request, :trail

  def init
    # id = params[:id] || params[:virtual_account_transaction_id]
    # self.virtual_account_transaction = ::VirtualAccountTransaction.find_by(id: id)
    self.virtual_account = self.virtual_account_transaction.virtual_account
    self.trail = ::VirtualAccountCollectTrail.find_by(id: options[:trail_id])
    self.company = virtual_account.company
    self.payment_request = init_payment_request(:virtual_bank_account, virtual_account.receiving_account)
  end

  def validate
    if self.virtual_account.blank?
      add_message :error, "Virtual bank account number not found"
    end
    if self.virtual_account.expires_by && self.virtual_account.expires_by < DateUtils.local_date
      add_message :error, "This virtual account has expired"
    end
  end

  def process
    # triggering the operation for creating the payment
    # and marks the respective payment against it
    op = AccountManager::Payments::PaymentProcessor.(self.virtual_account.initiating_user, payment_request: self.payment_request)
    if op.success?
      payment = op.payment_order&.payments.first
      payment.update(reference_resource: self.virtual_account_transaction)
      self.trail.update(create_payment: true, update_company_balance: true)
      self.virtual_account_transaction.update(processed: true)
    else
      add_message :error, op.messages[:error]
      self.trail.update(note: self.messages[:error].to_sentence, update_company_balance: false, create_payment: false)
    end
  end

  def post_process
    # trigger mailers if necessary
  end

  def success

  end

  def failure

  end
end
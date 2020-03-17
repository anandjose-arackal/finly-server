# this operation will use the API handler for payment status check and
# return sthe status of all payments initiated from our end in the system
class BankTransfer::Icici::Transactions::CheckStatus < BaseOperation

  attr_accessor :bank_transaction, :company, :payment, :payment_order

  def self.call(bank_transaction)
    self.new(bank_transaction).run
  end

  def initialize(bank_transaction)
    self.bank_transaction = bank_transaction
    self.company = bank_transaction.company
    self.payment = bank_transaction.reference_payment
    self.payment_order = self.payment&.payment_order
  end

  def validate
    unless self.bank_transaction.pending_utr? || self.bank_transaction.processing? || self.bank_transaction.pending_for_processing? || self.bank_transaction.possible_failure? || self.bank_transaction.suspect?
      add_message :error, "This transaction is not in processing state"
      return
    end
  end

  def process
    op = IciciBankApi::TransactionStatus.(self.bank_transaction)
    if op.success?
      if self.bank_transaction.completed?
        self.payment.update(payment_status_id: PaymentStatus.id_for(:completed))
        if self.payment&.invoice.present?
          self.payment&.invoice&.update_invoice_status
        end
        self.payment_order.update_order_status
        self.payment_order.update_processed_amount
        self.payment.system_messages.destroy_all
        self.payment_order.execute_post_operation(true)
      elsif self.bank_transaction.failed?
        self.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        self.payment_order.update_order_status
        self.payment_order.update_processed_amount
        self.payment_order.execute_post_operation(true)
      elsif self.bank_transaction.rejected?
        self.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        self.payment.system_messages.build(content: "This payment has been rejected from your net banking dashboard", system_message_type_id: SystemMessageType.id_for(:error)).save
        self.payment_order.update_order_status
        self.payment_order.update_processed_amount
        self.payment_order.execute_post_operation(true)
      end
    else
      if self.bank_transaction.failed?
        self.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        self.payment_order.update_order_status
        self.payment_order.update_processed_amount
        self.payment_order.execute_post_operation(true)
      end
    end
  end

  def post_process
    # trigger event for sending mailer to the receiver of the payment
    if self.payment&.completed?
      #Event::EBankPaymentRequest::EPayment::CreditConfirm.(payment.initiating_user, payment: self.payment) rescue nil
      execute_callback(self.payment)
    elsif payment&.failed?
      execute_callback(self.payment)
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
    # creating the webhook track based on the response of the particular operation
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

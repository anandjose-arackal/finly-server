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
end
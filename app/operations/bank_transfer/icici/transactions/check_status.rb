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
    self.payment = bank_transaction.payment
    self.payment_order = self.payment&.payment_order
  end

  def validate
    unless self.bank_transaction.pending_utr? || self.bank_transaction.processing? || self.bank_transaction.pending_for_processing?
      add_message :error, "This transaction is not in processing state"
      return
    end
  end

  def process
    op = IciciBankApi::TransactionStatus.(self.bank_transaction)
    if op.success?
      if self.bank_transaction.completed?
        unless self.bank_transaction.neft?
          self.payment.update(payment_status_id: PaymentStatus.id_for(:completed))
          self.payment_order.update_order_status
          self.payment_order.update_processed_amount
        end
        self.payment.system_messages.destroy_all
      elsif self.bank_transaction.failed?
        self.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        self.payment_order.update_order_status
        self.payment_order.update_processed_amount
      end
    end
  end
end

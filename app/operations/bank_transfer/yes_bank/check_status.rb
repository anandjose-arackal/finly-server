# this operation will accept a particular bank transaction and checks its status if it's a
# Bank transaction that is in processing state

class BankTransfer::YesBank::CheckStatus < BankTransfer::YesBank::Base

  attr_accessor :bank_transaction, :payment

  def self.call(bank_transaction)
    self.new(bank_transaction).run
  end

  def initialize(bank_transaction)
    self.bank_transaction = bank_transaction
  end

  def authorized_user_types
    []
  end

  def pre_validate
    if bank_transaction.nil?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    # getting the associated payment for this bank transaction
    self.payment = bank_transaction.payment
  end

  def validates
    # confirm that the bank transaction is, in fact in processing state
    unless bank_transaction.processing?
      add_message :error, "This transaction is not in processing state"
      return
    end
  end

  def process
    params = {
        request_reference_number: bank_transaction.unique_request_number
    }
    op = YesBankApi::Status::GetStatus.(params)
    if op.success?
      if Constants::YesBank::SUCCESSFUL_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
        payment&.update(payment_status_id: PaymentStatus.id_for(:completed))
        payment.system_messages.destroy_all
      elsif Constants::YesBank::PROCESSING_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
        payment&.update(payment_status_id: PaymentStatus.id_for(:processing))
      elsif Constants::YesBank::FAILED_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        payment&.update(payment_status_id: PaymentStatus.id_for(:failed))
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "The amount will be refunded to your bank account shortly").save
        create_refund_payment(payment)
      else
        # do nothing?
      end
    end
  end

  private

  def create_refund_payment(payment)
    # todo - implement this for refunded payments
  end
end
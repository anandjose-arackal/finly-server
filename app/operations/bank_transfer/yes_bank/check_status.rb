# this operation will accept a particular bank transaction and checks its status if it's a
# Bank transaction that is in processing state

class BankTransfer::YesBank::CheckStatus < BankTransfer::YesBank::Base

  attr_accessor :bank_transaction

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
      elsif Constants::YesBank::PROCESSING_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
      elsif Constants::YesBank::FAILED_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
      else
        # do nothing?
      end
    end
  end

  # nothing else to do because this is a backgrund operation
end
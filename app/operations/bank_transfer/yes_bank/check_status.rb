# this operation will accept a particular bank transaction and checks its status if it's a
# Bank transaction that is in processing state

class BankTransfer::YesBank::CheckStatus < BankTransfer::YesBank::Base

  attr_accessor :bank_transaction

  def initialize(bank_transaction)
    self.bank_transaction = bank_transaction
  end

  def pre_validate
    if bank_transaction.nil?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def process
    params = {
        bank_transaction: bank_transaction.unique_request_number
    }
    op = YesBank::Status::GetStatus.(params)
    if op.success?
      if op.request_status.downcase == "completed"
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
      elsif op.request_status.downcase == "sent_to_beneficiary"
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
      elsif op.request_status.downcase == "failed"
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
      else
        # do nothing?
      end
    end
  end

  # nothing else to do because this is a backgrund operation
end
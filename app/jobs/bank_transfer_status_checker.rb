class BankTransferStatusChecker < ApplicationJob

  def perform
    pending_transactions = BankTransaction.processing_transactions.all
    # pending_transactions = BankTransaction.where(id: 49)
    pending_transactions.each do |trans|
      # where all the magic happens!
      BankTransfer::YesBank::CheckStatus.(trans)
    end
  end
end
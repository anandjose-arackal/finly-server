class BankTransferStatusChecker < ActiveJob::Base

  def perform
    pending_transactions = BankTransaction.processing_transaction.all
    pending_transactions.each do |trans|
      # where all the magic happens!
      BankTransfer::YesBank::CheckStatus.(trans)
    end
  end
end
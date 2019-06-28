class BankTransferStatusChecker < ApplicationJob

  def perform
    pending_transactions = YesBankTransaction.processing_transactions.non_penny_test.all
    pending_transactions.each do |trans|
      # where all the magic happens!
      BankTransfer::YesBank::CheckStatus.(trans)
    end
  end
end
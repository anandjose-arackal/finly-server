class YesBankStatusChecker

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------"

    pending_transactions = YesBankTransaction.processing_transactions.non_penny_test.all
    pending_transactions.each do |trans|
      # where all the magic happens!
      BankTransfer::YesBank::CheckStatus.(trans)
    end

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end
end
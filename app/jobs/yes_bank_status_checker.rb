class YesBankStatusChecker

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    pending_transactions = YesBankTransaction.processing_transactions.non_penny_test.all
    pending_transactions.each do |trans|
      # where all the magic happens!
      BankTransfer::YesBank::CheckStatus.(trans)
    end

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end
end
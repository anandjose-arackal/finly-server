class IciciStatusChecker < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name}  at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    # this operation will check for the payment status of all ICICI initiated payments
    # pending_transactions = IciciBankTransaction.processing_transactions
    # pending_transactions.each do |bank_transaction|
    #   BankTransfer::Icici::Transactions::CheckStatus.(bank_transaction)
    # end

    handle = self.object_id
    IciciBankStatusCheckerBackground.perform_async(handle, nil)

    # below block is no longer relevant because
    # # For NEFT payments alone, since the UTR doesn't come in the status API we have to further compare it with the
    # # statements to ensure the UTR is available
    # pending_neft_transactions = IciciBankTransaction.neft.completed
    # pending_neft_transactions.each do |bank_transaction|
    #   BankTransfer::Icici::Transactions::CheckStatusNeft.(bank_transaction)
    # end

    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
  end
end
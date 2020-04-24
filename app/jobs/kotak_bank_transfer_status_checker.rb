# job that cycles through all users and sets the balances for all of them
class KotakBankTransferStatusChecker

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    # Find all kotak bank transaction where UTR is not present
    # Pass through Kotak Bank Status API and update bank transactions
    #
    # Tasks:
    # 1. Update UTR
    # 2. Check Status of Payment
    #   a. Update Payment
    #   b. If failed > Update Payment
    # bank_transactions = KotakBankTransaction.without_utr.status_check_required
    #
    # bank_transactions.each do |bank_transaction|
    #   parameters = {
    #       unique_reference_number: bank_transaction.unique_reference_number,
    #       company_id: bank_transaction.company_id,
    #       bank_transaction: bank_transaction
    #   }
    #   op = KotakBankApi::TransactionStatus.(parameters)
    #   unless op.success?
    #     p "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    #     p op.messages
    #     p "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    #   end
    # end

    handle = self.object_id
    KotakBankStatusCheckerBackground.perform_async(handle, nil)

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end
end
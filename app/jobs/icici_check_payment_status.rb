class IciciCheckPaymentStatus < ActiveJob::Base

  def perform
    # this operation will check for the payment status of all ICICI initiated payments
    pending_transactions = IciciBankTransaction.processing_transactions
    pending_transactions.each do |bank_transaction|
      BankTransfer::Icici::Transactions::CheckStatus.(bank_transaction)
    end
  end
end
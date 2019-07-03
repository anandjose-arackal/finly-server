class IciciCheckPaymentStatus < ActiveJob::Base

  def perform
    # this operation will check for the payment status of all ICICI initiated payments
    pending_transactions = IciciBankTransaction.processing_transactions.non_penny_test.all

  end
end
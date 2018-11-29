class BankTransferProcessRetry < ActiveJob::Base
  def perform
    failed_payments_for_retry = Payment.where(payment_status_id: PaymentStatus.id_for(:pending_retry))
    if failed_payments_for_retry.present?
      failed_payments_for_retry.each do |payment|
      end
    end
  end
end
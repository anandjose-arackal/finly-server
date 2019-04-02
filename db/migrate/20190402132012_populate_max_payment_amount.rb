class PopulateMaxPaymentAmount < ActiveRecord::Migration[5.2]
  def change
    status_ids = BankPaymentRequest.status_ids(:open, :processing, :retracted, :rejected, :approved, :auto_approved)
    bank_payment_requests = BankPaymentRequest.where(status_id: status_ids)


    bank_payment_requests.each do |bank_payment_request|
      max_payment_amount = bank_payment_request.payment_order.payments.joins(:amount).pluck(:value).max
      bank_payment_request.update(max_payment_amount: max_payment_amount)
    end
  end
end

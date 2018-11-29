class AddPaymentStatusFailedRetry < ActiveRecord::Migration
  def change
    PaymentStatus.create(id: 11,name: "pending_retry")
  end
end

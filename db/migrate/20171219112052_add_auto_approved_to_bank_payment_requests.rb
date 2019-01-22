class AddAutoApprovedToBankPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :auto_approved, :boolean
  end
end

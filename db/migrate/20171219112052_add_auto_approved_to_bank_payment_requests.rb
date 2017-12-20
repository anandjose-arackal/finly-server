class AddAutoApprovedToBankPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :auto_approved, :boolean
  end
end

class AddIsDeletedToBankPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :is_deleted, :boolean
    BankPaymentRequest.update_all(is_deleted: false)
  end
end

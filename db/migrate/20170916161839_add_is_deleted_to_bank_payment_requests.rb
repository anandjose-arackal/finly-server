class AddIsDeletedToBankPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :is_deleted, :boolean
    BankPaymentRequest.unscoped.update_all(is_deleted: false)
  end
end

class AddRequireApprovalToBankPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :require_approval, :boolean
  end
end

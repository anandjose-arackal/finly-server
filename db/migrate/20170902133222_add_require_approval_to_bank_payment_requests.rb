class AddRequireApprovalToBankPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :require_approval, :boolean
  end
end

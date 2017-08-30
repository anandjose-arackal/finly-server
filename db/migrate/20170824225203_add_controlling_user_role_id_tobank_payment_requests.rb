class AddControllingUserRoleIdTobankPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :controlling_user_role_id, :integer, references: "UserRole", foreign_key: true, index: true
  end
end

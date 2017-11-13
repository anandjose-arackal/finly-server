class AddPolicyToPaymentRequests < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :policy_id, :integer, references: "Policy", foreign_key: true, index: true
  end
end

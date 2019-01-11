class AddPolicyToPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :policy_id, :integer, references: "Policy", foreign_key: true, index: true
  end
end

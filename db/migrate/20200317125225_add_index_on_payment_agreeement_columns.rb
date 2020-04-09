class AddIndexOnPaymentAgreeementColumns < ActiveRecord::Migration[5.2]
  def change
    add_index :payment_agreements, :policy_id
    add_index :payment_agreements, :creator_id
    add_index :payment_agreements, :status_id
    add_index :payment_agreements, [:company_id, :status_id, :policy_id, :created_at], name: :payment_agreement_joined_indeexes
  end
end

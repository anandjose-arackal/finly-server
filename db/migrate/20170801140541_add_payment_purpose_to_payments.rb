class AddPaymentPurposeToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :payment_purpose_id, :integer
    add_column :payments, :reference_resource_id, :integer
    add_column :payments, :reference_resource_type, :string
  end
end

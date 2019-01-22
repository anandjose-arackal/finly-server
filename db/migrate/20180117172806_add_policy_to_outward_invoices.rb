class AddPolicyToOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :policy_id, :integer, references: "Policy", foreign_key: true, index: true
    add_column :outward_invoices, :billing_address_id, :integer, references: "Address", foreign_key: true, index: true
    add_column :outward_invoices, :shipping_address_id, :integer, references: "Address", foreign_key: true, index: true
  end
end

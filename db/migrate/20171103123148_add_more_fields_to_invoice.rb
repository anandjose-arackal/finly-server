class AddMoreFieldsToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :gross_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :invoices, :net_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :invoices, :inclusive_of_taxes, :boolean, references: "Amount", foreign_key: true, index: true
  end
end

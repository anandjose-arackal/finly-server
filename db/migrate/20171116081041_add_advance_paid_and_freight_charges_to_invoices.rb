class AddAdvancePaidAndFreightChargesToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :advance_amount_id, :integer, references: "Amount", index: true, foreign_key: true
    add_column :invoices, :advance_type_id, :integer
    add_column :invoices, :advance, :decimal, precision: 20, scale: 10
    add_column :invoices, :freight_amount_id, :integer, references: "Amount", index: true, foreign_key: true
    add_column :invoices, :freight_type_id, :integer
    add_column :invoices, :freight, :decimal, precision: 20, scale: 10
  end
end

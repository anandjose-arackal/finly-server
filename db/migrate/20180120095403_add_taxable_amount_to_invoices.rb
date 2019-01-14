class AddTaxableAmountToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :taxable_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end

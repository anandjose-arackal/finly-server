class AddGrossAmountToOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :gross_amount_id, :integer, foreign_key: true, index: true
  end
end

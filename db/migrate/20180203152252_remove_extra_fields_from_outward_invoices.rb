class RemoveExtraFieldsFromOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    remove_column :outward_invoices, :original_amount_id, :integer
    remove_column :outward_invoices, :gross_amount_id, :integer
  end
end
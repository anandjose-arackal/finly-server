class ChangeNamesOfMemoColumnInOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :customer_memo, :text
  end
end

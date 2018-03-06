class ChangeNamesOfMemoColumnInOutwardInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :customer_memo, :text
  end
end

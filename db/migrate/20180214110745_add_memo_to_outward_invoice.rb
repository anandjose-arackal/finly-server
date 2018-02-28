class AddMemoToOutwardInvoice < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :memo, :string
  end
end
class AddMemoToOutwardInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :memo, :string
  end
end
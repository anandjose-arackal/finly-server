class AddCostCenterToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :cost_center_id, :integer
  end
end

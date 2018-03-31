class AddCostCenterToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :cost_center_id, :integer
  end
end

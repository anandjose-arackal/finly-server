class AddDepartmentToPurchaseOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_orders, :department_id, :integer, references: "Department", foreign_key: true, index: true
  end
end
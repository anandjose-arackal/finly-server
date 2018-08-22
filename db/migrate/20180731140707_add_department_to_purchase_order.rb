class AddDepartmentToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :department_id, :integer, references: "Department", foreign_key: true, index: true
  end
end
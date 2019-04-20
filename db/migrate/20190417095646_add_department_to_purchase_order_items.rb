class AddDepartmentToPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_items, :department_id, :integer, references: 'Department', foreign_key: true
    add_index :purchase_order_items, :department_id
  end
end

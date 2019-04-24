class AddDepartmentAndCcToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :department_id, :integer, references: 'Department', foreign_key: true
    add_column :purchase_request_items, :cost_center_id, :integer, references: 'CostCenter', foreign_key: true

    add_index :purchase_request_items, :department_id
    add_index :purchase_request_items, :cost_center_id

  end
end

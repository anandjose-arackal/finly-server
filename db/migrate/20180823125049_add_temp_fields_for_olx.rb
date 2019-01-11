class AddTempFieldsForOlx < ActiveRecord::Migration[4.2]
  def change

    # Temporary for olx
    add_column :inventory_line_items, :item_code, :string
    add_column :inventory_line_items, :account, :string
    add_column :purchase_order_items, :account, :string
    add_column :invoice_line_items, :account, :string

    # Permanent
    add_column :purchase_orders, :cost_center_id, :integer, references: 'CostCenter', foreign_key: true, index: true
    add_column :purchase_orders, :sub_department_id, :integer, references: 'Department', foreign_key: true, index: true
    add_column :invoices, :department_id, :integer, references: 'Department', foreign_key: true, index: true
    add_column :invoices, :sub_department_id, :integer, references: 'Department', foreign_key: true, index: true
  end
end

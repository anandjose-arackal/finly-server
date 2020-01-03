class RenameColumnNameInBill < ActiveRecord::Migration[5.2]
  def change
    rename_column :bbps_bills, :validation_order_number, :order_number
    add_column :bbps_bills, :order_number_type, :string
  end
end

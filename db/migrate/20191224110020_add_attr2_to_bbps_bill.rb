class AddAttr2ToBbpsBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :validation_order_number, :string
  end
end

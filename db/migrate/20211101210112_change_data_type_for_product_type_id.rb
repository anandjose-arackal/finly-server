class ChangeDataTypeForProductTypeId < ActiveRecord::Migration[6.0]
  def change
    if ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :product_type_id)
      change_column :purchase_order_items, :product_type_id, :integer
    end
  end
end

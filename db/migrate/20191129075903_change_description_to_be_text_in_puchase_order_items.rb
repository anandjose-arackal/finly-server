class ChangeDescriptionToBeTextInPuchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_order_items, :description, :text
  end
end

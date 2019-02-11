class AddForeignKeyPoGstType < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :purchase_orders, :gst_types, column: :gst_type_id
  end
end

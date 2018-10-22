class AddForeignKeyPoGstType < ActiveRecord::Migration
  def change
    add_foreign_key :purchase_orders, :gst_types, column: :gst_type_id
  end
end

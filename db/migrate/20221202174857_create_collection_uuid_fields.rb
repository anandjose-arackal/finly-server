class CreateCollectionUuidFields < ActiveRecord::Migration[6.0]
  def change
    add_column :invoice_line_items, :collection_uuid, :string
    add_column :purchase_order_items, :collection_uuid, :string
    add_column :purchase_request_items, :collection_uuid, :string
    add_column :form_custom_fields, :collection_uuid, :string

    add_index :form_custom_fields, :collection_uuid
  end
end

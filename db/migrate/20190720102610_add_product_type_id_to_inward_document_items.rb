class AddProductTypeIdToInwardDocumentItems < ActiveRecord::Migration[5.2]
  def change
    add_column :inward_document_items, :product_type_id, :integer, default: 1, references: "ProductType", foreign_key: true
	add_index :inward_document_items, :product_type_id
  end
end

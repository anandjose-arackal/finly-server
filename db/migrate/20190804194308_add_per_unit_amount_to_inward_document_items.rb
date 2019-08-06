class AddPerUnitAmountToInwardDocumentItems < ActiveRecord::Migration[5.2]
  def change
    add_column :inward_document_items, :per_unit_amount_id, :integer
    add_index :inward_document_items, :per_unit_amount_id
  end
end

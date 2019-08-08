class RenameColumnPerUnitAmount < ActiveRecord::Migration[5.2]
  def change
    rename_column :inward_document_items, :per_unit_amount_id, :accepting_item_amount_id
  end
end

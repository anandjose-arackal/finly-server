class AddItemTypeToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :item_subtype, :string, null: true
  end
end

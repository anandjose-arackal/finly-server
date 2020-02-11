class CreateUserDropDownItemMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_drop_down_item_mappings do |t|
      t.integer :user_id, references: "User", foreign_key: true, index: true
      t.integer :drop_down_item_id, references: "FieldDropDownItem", foreign_key: true, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end

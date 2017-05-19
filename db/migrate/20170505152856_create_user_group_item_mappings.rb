class CreateUserGroupItemMappings < ActiveRecord::Migration
  def change
    create_table :user_group_item_mappings do |t|
      t.references :user, index: true, foreign_key: true
      t.references :user_group_item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

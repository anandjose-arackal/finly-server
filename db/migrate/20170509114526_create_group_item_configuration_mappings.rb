class CreateGroupItemConfigurationMappings < ActiveRecord::Migration
  def change
    create_table :group_item_configuration_mappings do |t|
      t.references :user_group_configuration, null: false, index: true, foreign_key: true
      t.references :user_group, null: false, index: true, foreign_key: true
      t.references :user_group_item, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

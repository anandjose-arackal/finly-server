class CreateUserGroupConfigurationTypes < ActiveRecord::Migration
  def change
    create_table :user_group_configuration_types do |t|

      t.timestamps null: false
    end
    UserGroupConfigurationType.seed_data
    add_column :user_group_configurations, :type_id, :integer, references: 'UserGroupConfigurationType', null: false, index: true, foreign_key: true
    add_column :group_item_configuration_mappings, :type_id, :integer, references: 'UserGroupConfigurationType', null: false, index: true, foreign_key: true
  end
end

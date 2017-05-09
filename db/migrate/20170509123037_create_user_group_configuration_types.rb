class CreateUserGroupConfigurationTypes < ActiveRecord::Migration
  def change
    create_table :user_group_configuration_types do |t|

      t.timestamps null: false
    end
    add_column :user_group_configurations, :type_id, :integer, references: 'UserGroupConfigurationType', null: false, index: true, foreign_key: true
  end
end

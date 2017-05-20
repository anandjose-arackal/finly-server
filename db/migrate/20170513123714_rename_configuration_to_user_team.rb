class RenameConfigurationToUserTeam < ActiveRecord::Migration
  def change
    remove_index :user_team_group_item_mappings, :configuration_id
    remove_column :user_team_group_item_mappings, :configuration_id
    add_reference :user_team_group_item_mappings, :user_team, index: true, foreign_key: true
  end
end

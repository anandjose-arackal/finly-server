class RenameUserGroupConfigurationToTeam < ActiveRecord::Migration[4.2]
  def change
    rename_table :user_group_configurations, :teams
    add_column :teams, :name, :string, null: false
  end
end

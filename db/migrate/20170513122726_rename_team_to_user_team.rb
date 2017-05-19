class RenameTeamToUserTeam < ActiveRecord::Migration
  def change
    rename_table :teams, :user_teams
    rename_table :team_group_item_mappings, :user_team_group_item_mappings
  end
end

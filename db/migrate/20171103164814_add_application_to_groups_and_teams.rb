class AddApplicationToGroupsAndTeams < ActiveRecord::Migration
  def change
    add_column :user_groups, :application, :string
    add_column :user_teams, :application, :string
  end
end

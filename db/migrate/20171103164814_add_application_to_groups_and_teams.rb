class AddApplicationToGroupsAndTeams < ActiveRecord::Migration[4.2]
  def change
    add_column :user_groups, :application, :string
    add_column :user_teams, :application, :string
  end
end

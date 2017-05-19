class RenameGroupItemConfigurationMappingToTeamGroupItemMapping < ActiveRecord::Migration
  def change
    rename_table :group_item_configuration_mappings, :team_group_item_mappings
  end
end

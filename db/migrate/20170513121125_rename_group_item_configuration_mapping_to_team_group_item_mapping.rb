class RenameGroupItemConfigurationMappingToTeamGroupItemMapping < ActiveRecord::Migration[4.2]
  def change
    rename_table :group_item_configuration_mappings, :team_group_item_mappings
  end
end

class AddTravelManagerIdToUserManagerMappings < ActiveRecord::Migration[4.2]
  def change
    add_column :user_manager_mappings, :travel_manager_id, :integer, references: "User", foreign_key: true, index: true
  end
end

class AddTravelApprovesTo < ActiveRecord::Migration
  def change
    add_column :user_manager_mappings, :travel_approves_to_id, :integer, references: 'User', index: true, foreign_key: true
  end
end

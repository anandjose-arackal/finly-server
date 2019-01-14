class AddTravelBookingSelectorToUserManagerMappings < ActiveRecord::Migration[4.2]
  def change
    add_column :user_manager_mappings, :travel_booking_selector, :integer, references: 'User', index: true, foreign_key: true
    add_column :user_manager_mappings, :travel_booking_approves_to, :integer, references: 'User', index: true, foreign_key: true
  end
end

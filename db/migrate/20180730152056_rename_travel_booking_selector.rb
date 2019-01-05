class RenameTravelBookingSelector < ActiveRecord::Migration[4.2]
  def change
    rename_column :user_manager_mappings, :travel_booking_selector, :travel_booking_selector_id
    rename_column :user_manager_mappings, :travel_booking_approves_to, :travel_booking_approves_to_id
  end
end

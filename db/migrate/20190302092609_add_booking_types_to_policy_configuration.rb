class AddBookingTypesToPolicyConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :policy_configurations, :booking_type_flight, :boolean, default: true
    add_column :policy_configurations, :booking_type_car_rental, :boolean, default: true
    add_column :policy_configurations, :booking_type_bus, :boolean, default: true
    add_column :policy_configurations, :booking_type_train, :boolean, default: true
    add_column :policy_configurations, :booking_type_hotel, :boolean, default: true
    add_column :policy_configurations, :booking_type_restaurant, :boolean, default: true
    add_column :policy_configurations, :booking_type_other, :boolean, default: true
  end
end
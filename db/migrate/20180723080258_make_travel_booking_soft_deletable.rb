class MakeTravelBookingSoftDeletable < ActiveRecord::Migration[4.2]
  def change
    add_column :booking_requests, :is_deleted, :boolean, index: true, default: false
    add_column :booking_flights, :is_deleted, :boolean, index: true, default: false
    add_column :booking_buses, :is_deleted, :boolean, index: true, default: false
    add_column :booking_trains, :is_deleted, :boolean, index: true, default: false
    add_column :booking_hotels, :is_deleted, :boolean, index: true, default: false
    add_column :booking_restaurants, :is_deleted, :boolean, index: true, default: false
    add_column :booking_customs, :is_deleted, :boolean, index: true, default: false
    add_column :locations, :is_deleted, :boolean, index: true, default: false
    add_column :travel_request_trails, :is_deleted, :boolean, index: true, default: false
    add_column :travel_request_comments, :is_deleted, :boolean, index: true, default: false
  end
end

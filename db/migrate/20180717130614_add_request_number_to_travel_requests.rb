class AddRequestNumberToTravelRequests < ActiveRecord::Migration
  def change
    add_column :travel_requests, :request_number, :string
  end
end

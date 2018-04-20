class AddAutoApprovedToTravelRequest < ActiveRecord::Migration
  def change
    add_column :travel_requests, :auto_approved, :boolean
  end
end

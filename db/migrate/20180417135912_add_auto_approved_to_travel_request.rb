class AddAutoApprovedToTravelRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :travel_requests, :auto_approved, :boolean
  end
end

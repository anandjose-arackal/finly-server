class AddCompanyIdToTravelRequest < ActiveRecord::Migration
  def change
    add_reference :travel_requests, :company, index: true

  end
end

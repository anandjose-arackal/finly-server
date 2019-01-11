class AddCompanyIdToTravelRequest < ActiveRecord::Migration[4.2]
  def change
    add_reference :travel_requests, :company, index: true

  end
end

class SeedTravelRequestStatuses < ActiveRecord::Migration[4.2]
  def change
    TravelRequestStatus.seed_data
    BookingType.seed_data
  end
end

class SeedTravelRequestStatuses < ActiveRecord::Migration
  def change
    TravelRequestStatus.seed_data
    BookingType.seed_data
  end
end

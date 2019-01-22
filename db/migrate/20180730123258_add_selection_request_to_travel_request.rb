class AddSelectionRequestToTravelRequest < ActiveRecord::Migration[4.2]
  def change
    TravelRequestStatus.seed_data
    TravelRequestTrailAction.seed_data
    BankPaymentRequestCommentAction.seed_data
    BookingStatus.seed_data
    add_column :travel_requests, :approved_at, :datetime
    add_column :travel_requests, :selection_requested_at, :datetime
  end
end

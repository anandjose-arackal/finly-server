class AddBookingRequestToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :travel_requests, :booking_request_id, :integer, references: "BookingRequest", foreign_key: true, index: true
  end
end

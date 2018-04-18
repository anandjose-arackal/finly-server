class TravelRequests::Review::FinishBooking < TravelRequests::Review::Base

  def authorized_user_types
    [:company_admin, :travel_manager]
  end

  def validate
    # checking if all the booking requests in the travel request have attached bookings
    spurious_booking_requests = []
    self.travel_request.destinations.each do |destination|
      destination.booking_requests.each do |booking_request|
        if booking_request.bookings.empty?
          spurious_booking_requests << "#{booking_request.booking_type&.name&.humanize} request to #{destination.name} does not have an associated booking"
        end
      end
    end
    if spurious_booking_requests.present?
      add_message :error, spurious_booking_requests
      return
    end

    # checking if the travel request can be confirmed as boked
    unless self.travel_request.can_finish_booking?
      add_message :error, "Travel request cannot be marked as finished in this state"
      return
    end
  end

  def process

  end

  def post_process

  end
end
class TravelRequests::Review::FinishBooking < TravelRequests::Review::Base

  attr_accessor :role_id

  def authorized_user_types
    [:company_admin, :travel_manager]
  end

  def pre_validate
    super
    if params[:view].blank?
      add_message :error, "Invalid request, try again"
    end
  end

  def init
    super
    self.role_id = UserRole.id_for(params[:view].to_s)
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
    if travel_request.update status_id: TravelRequestStatus.id_for(:booked),
                             controlling_user: travel_request.user,
                             controlling_user_role_id: UserRole.id_for(:employee),
                             controlling_for_user_id: nil,
                             controlling_for_user_role_id: nil
      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: self.role_id,
                                                  action_for_user_id: nil,
                                                  action_for_user_role_id: nil,
                                                  action_id: TravelRequestTrailAction.id_for(:book),
                                                  modified_user_id: travel_request.user_id,
                                                  modified_user_role_id: UserRole.id_for(:employee)
    else
      add_message :error, self.travel_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Travel request booked"

    # add comments and trigger mailer
  end
end
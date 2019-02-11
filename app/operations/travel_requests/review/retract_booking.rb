# this operation will retract a travel booking from the booked state to the booking pending state, where in
# case there was an error in booking,
class TravelRequests::Review::RetractBooking < TravelRequests::Review::Base

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

    # unless travel_request.controlling_user_id == user.id
    #   add_message :error, "Cannot retract booking in this state"
    #   return
    # end

    # checking if the travel request can be confirmed as boked
    unless self.travel_request.can_retract_botraveloking?
      add_message :error, "Travel request cannot be marked as finished in this state"
      return
    end
  end

  def process
    if travel_request.update status_id: TravelRequestStatus.id_for(:booking_pending),
                             controlling_user: user,
                             controlling_user_role_id: UserRole.id_for(:travel_manager),
                             controlling_for_user_id: nil,
                             controlling_for_user_role_id: nil
      travel_request.travel_request_trails.create action_user: user,
                                                  action_user_role_id: self.role_id,
                                                  action_for_user_id: nil,
                                                  action_for_user_role_id: nil,
                                                  action_id: TravelRequestTrailAction.id_for(:retract_booking),
                                                  modified_user_id: user.id,
                                                  modified_user_role_id: UserRole.id_for(:travel_manager)
    else
      add_message :error, self.travel_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Travel booking successfully retracted"

    #todo - abi
    travel_request.money_requests.status_pending.update_all(
        controlling_user_id: travel_request.controlling_user_id,
        controlling_user_role_id: travel_request.controlling_user_role_id
    )
    travel_request.comments.create user_id: user.id,
                                   action_id: TravelRequestCommentAction.id_for(:remove_booking)
  end

end
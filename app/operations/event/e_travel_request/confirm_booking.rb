class Event::ETravelRequest::ConfirmBooking < Event::ETravelRequest::Base

  def event_id
    NotifierType.id_for(:travel_request_confirm_booking)
  end

  def action_name
    "Trip Booking Confirmed"
  end

  def affected_users
    # [self.travel_request.user, self.travel_request.controlling_user]
    [self.travel_request.user, self.travel_request.trails.last.action_user]
  end

  def mailer_subject(user)
    if user.id == travel_request.user.id
      "Trip Booking Confirmed : #{self.travel_request.trip_id}"
    else
      "#{self.travel_request.user.name} has confirmed the booking for the trip: #{self.travel_request.trip_id}"
    end
  end

  def mailer_body(user)
    if user.id == travel_request.user.id
      "Your booking has been confirmed for the trip: #{self.travel_request.trip_id}"
    else
      "#{self.travel_request.user.name} has confirmed the booking for the trip : #{self.travel_request.trip_id} and is currently awaiting approval."
    end
  end

  def travel_request_view_role(user)
    # if user.id == travel_request.user_id
    #   return UserRole.id_for(:employee)
    # elsif user.id == travel_request.controlling_user_id
    #   return travel_request.controlling_user_role_id
    # elsif user.id == self.travel_request.trails.last.action_user_id
    #   return self.travel_request.trails.last.action_user_role_id
    # end
    if self.travel_request.document_role_users(:travel_manager).include?(user)
      return UserRole.id_for(:travel_manager)
    elsif user.id == self.travel_request.user_id
      return UserRole.id_for(:employee)
    elsif self.travel_request.get_reviewers('current', 'TravelRequestBookingProvider').include?(user)
      return UserRole.id_for(:travel_manager)
    end
  end
end
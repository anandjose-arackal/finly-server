class Event::ETravelRequest::ConfirmSelection < Event::ETravelRequest::Base

  def event_id
    NotifierType.id_for(:travel_request_confirm_selection)
  end

  def action_name
    "Trip Booking Options Selection Confirmed"
  end

  def affected_users
    # [self.travel_request.user, self.travel_request.controlling_user]
    # [self.travel_request.user, self.travel_request.get_reviewers('current', 'TravelRequestBookingProvider')].flatten.compact.uniq rescue []
    [self.travel_request.user]
  end

  def mailer_subject(user)
    if user.id == travel_request.user.id
      "Trip Selection Confirmed : #{self.travel_request.trip_id}"
    else
      "#{self.travel_request.user.name} has confirmed the selection for the trip: #{self.travel_request.trip_id}"
    end
  end

  def mailer_body(user)
    if user.id == travel_request.user.id
      "Your booking options selection has been confirmed for the trip: #{self.travel_request.trip_id}"
    else
      "#{self.travel_request.user.name} has confirmed the booking option selection for the trip : #{self.travel_request.trip_id} and is currently awaiting your approval."
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
    if user.id == travel_request.user_id
      return UserRole.id_for(:employee)
    elsif travel_request.document_role_users(:travel_manager).include?(user)
      return UserRole.id_for(:travel_manager)
    else
      return UserRole.id_for(:manager)
    end
  end
end 
class Event::ETravelRequest::ApproveSelection < Event::ETravelRequest::Base


  def action_name
    "Trip Booking Option Selection Approval"
  end 

  def event_id
    NotifierType.id_for(:travel_request_approve_selection)
  end

  def affected_users
    [self.travel_request.user, self.travel_request.controlling_user]
  end

  def mailer_subject(user)
    "#{self.travel_request.user.name} has approved selection request for the trip #{self.travel_request.trip_id}"
  end

  def mailer_body(user)
    "#{self.travel_request.user.name} has approved booking options selection request for the trip #{self.travel_request.trip_id}"
  end

  def travel_request_view_role(user)
    if user.id == travel_request.user_id
      return UserRole.id_for(:employee)
    elsif user.id == travel_request.controlling_user_id
      return travel_request.controlling_user_role_id
    elsif user.id == self.travel_request.travel_request_trails.last.action_user_id
      return self.travel_request.travel_request_trails.last.action_user_role_id
    end
  end

end
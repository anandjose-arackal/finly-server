class Event::ETravelRequest::RequestSelection < Event::ETravelRequest::Base

  def event_id
    NotifierType.id_for(:travel_request_request_selection)
  end

  def action_name
    "Trip Requested for Selection"
  end

  def affected_users
    [self.travel_request.user]
  end

  def mailer_subject(user)
    "Trip Requested for Selection : #{self.travel_request.trip_id}"
  end

  def mailer_body(user)
    "#{self.travel_request.travel_request_trails.last.action_user.name} has requested for selection for the trip : #{self.travel_request.trip_id} and is curently awaiting your approval"
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
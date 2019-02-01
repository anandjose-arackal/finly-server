class Event::ETravelRequest::TakeControl < Event::ETravelRequest::Base

  def event_id
    NotifierType.id_for(:travel_request_take_control)
  end

  def action_name
    "Trip taken control of"
  end

  def affected_users
    [self.travel_request.user, self.travel_request.controlling_user, self.travel_request.controlling_for_user]
  end

  def mailer_subject(user)
    "#{self.travel_request.controlling_user.name} has taken control of the trip: #{self.travel_request.trip_id}"
  end

  def mailer_body(body)
    "#{self.travel_request.controlling_user.name} has taken control of the trip which was awaiting review,<br/><br/>Trip: \"#{self.travel_request.trip_id}\""
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
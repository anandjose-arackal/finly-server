class Event::ETravelRequest::Retract < Event::ETravelRequest::Base

  def event_id
    NotifierType.id_for(:travel_request_retract)
  end

  def action_name
    "Trip Retracted"
  end

  def affected_users
    # [self.travel_request.controlling_user, self.travel_request.trails&.order(:created_at)&.last&.modified_user]
    self.travel_request.affected_users(:retract)
  end

  def mailer_subject(user)
    if user.id == travel_request.user.id
      "Trip Retracted : #{self.travel_request.trip_id}"
    else
      "#{travel_request.user.name} has retracted the Trip: #{self.travel_request.trip_id}"
    end
  end

  def mailer_body(user)
    if user.id == travel_request.user.id
      "You have successfully retracted the trip : #{self.travel_request.trip_id}"
    else
      "#{travel_request.user.name} has successfully retracted trip #{self.travel_request.trip_id}"
    end
  end

  def travel_request_view_role(user)
    # Submission of trip is done by employee himself
    # if user.id == travel_request.user_id
    #   return UserRole.id_for(:employee)
    # elsif user.id == travel_request.controlling_user_id
    #   return travel_request.controlling_user_role_id
    # elsif user.id == self.travel_request.travel_request_trails.last.action_user_id
    #   return self.travel_request.travel_request_trails.last.action_user_role_id
    # end
    travel_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end
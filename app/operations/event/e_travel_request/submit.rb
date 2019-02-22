class Event::ETravelRequest::Submit < Event::ETravelRequest::Base

  def event_id
    NotifierType.id_for(:travel_request_submit)
  end

  def action_name
    "Trip Submitted"
  end

  def affected_users
    # [self.travel_request.user, self.travel_request.controlling_user]
    self.travel_request.affected_users(:submit)
  end

  def mailer_subject(user)
    if user.id == travel_request.user_id
      "Trip Submitted : #{self.travel_request.trip_id}"
    else
      "#{self.travel_request.user.name} has submitted the trip: #{self.travel_request.trip_id}"
    end
  end

  def mailer_body(user)
    if user.id == travel_request.user_id
      "Congratulations, you have successfully submitted the trip: #{self.travel_request.trip_id}"
    else
      "#{self.travel_request.user.name} has submitted the trip : #{self.travel_request.trip_id} and is currently awaiting your approval."
    end
  end

  def travel_request_view_role(user)
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
class Event::ETravelRequest::ApproveSelection < Event::ETravelRequest::Base


  def action_name
    "Trip Booking Option Selection Approval"
  end 

  def event_id
    NotifierType.id_for(:travel_request_approve_selection)
  end

  def affected_users
    # [self.travel_request.user, self.travel_request.controlling_user]
    [self.travel_request.user, self.travel_request.get_reviewers('current', 'TravelRequestBookingProvider'), self.travel_request.document_role_users(:travel_manager)].flatten.compact.uniq rescue []
  end

  def mailer_subject(user)
    # "#{self.travel_request.user.name} has approved selection request for the trip #{self.travel_request.trip_id}"
    "#{self.travel_request.user.name} has approved booking options selection request for the trip #{self.travel_request.trip_id} and is currently waiting for your approval"
  end

  def mailer_body(user)
    "#{self.travel_request.user.name} has approved booking options selection request for the trip #{self.travel_request.trip_id} and is currently waiting for your approval"
  end

  def travel_request_view_role(user)
    # if user.id == travel_request.user_id
    #   return UserRole.id_for(:employee)
    # elsif user.id == travel_request.controlling_user_id
    #   return travel_request.controlling_user_role_id
    # elsif user.id == self.travel_request.trails.last.action_user_id
    #   return self.travel_request.trails.last.action_user_role_id
    # end
    # self.travel_request.get_reviewers('current', 'TravelRequestBookingProvider').include?(user) ? UserRole.id_for(:travel_manager) : UserRole.id_for(:employee)
    if self.travel_request.document_role_users(:travel_manager).include?(user)
      return UserRole.id_for(:travel_manager)
    elsif travel_request.get_reviewers.include?(user)
      return UserRole.id_for(:manager)
    elsif user == travel_request.user_id
      return UserRole.id_for(:employee)
    end
  end

end
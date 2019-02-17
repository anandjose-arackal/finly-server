class Event::ETravelRequest::Reject < Event::ETravelRequest::Base

  attr_accessor :rejecting_user

  def init
    super
    self.rejecting_user = self.travel_request.trails&.order(:created_at)&.last&.action_user
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, "User not found"
    end
  end

  def event_id
    NotifierType.id_for(:travel_request_reject)
  end

  def action_name
    "Trip Rejected"
  end

  def affected_users
    # [self.travel_request.controlling_user, self.travel_request.travel_request_trails&.order(:created_at)&.last&.modified_user]
    self.travel_request.affected_users(:reject)
  end

  def mailer_subject(user)
    if user.id == self.rejecting_user.id
      "Trip Rejected : #{self.travel_request.trip_id}"
    else
      "#{self.rejecting_user.name} has rejected the trip: #{self.travel_request.trip_id}"
    end
  end

  def mailer_body(user)
    if user.id == self.rejecting_user.id
      "You have rejected the trip : #{self.travel_request.trip_id}"
    else
      "#{self.rejecting_user.name} has rejected the trip: '#{self.travel_request.trip_id}'"
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
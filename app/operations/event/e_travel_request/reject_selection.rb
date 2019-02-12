class Event::ETravelRequest::RejectSelection < Event::ETravelRequest::Base

 attr_accessor :rejecting_user, :roles

  def init
    super
    self.rejecting_user = self.travel_request.travel_request_trails&.order(:created_at)&.last&.action_user
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, "User not found"
    end
  end

  def event_id
    NotifierType.id_for(:travel_request_reject_selection)
  end

  def action_name
    "Trip Booking Options Selection Rejected"
  end

  def affected_users
    [self.travel_request.user, self.travel_request.controlling_user]
  end

  def mailer_subject(user)
    if user.id == travel_request.user.id
      "Trip Rejected : #{self.travel_request.trip_id}"
    else
      "#{self.travel_request.user.name} has rejected selection for the trip: #{self.travel_request.trip_id}"
    end
  end

  def mailer_body(user)
    if user.id == self.rejecting_user.id
      "You have rejected selection of booking options for the trip : #{self.travel_request.trip_id}"
    else
      "#{rejecting_user.name} has rejected selection of booking options for the trip: '#{self.travel_request.trip_id}'"
    end
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

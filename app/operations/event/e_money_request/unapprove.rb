class Event::EMoneyRequest::Unapprove < Event::EMoneyRequest::Base

  def event_id
    Event.money_request_unapprove_id
  end

  def affected_users
    [self.money_request.controlling_user, self.money_request.tracks.last.modified_user]
  end

  def send_push_notification(user)
    return if user.id == money_request.controlling_user_id
    message = "#{self.money_request.controlling_user.name} unapproved the Advance Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if money_request.controlling_user.id == user.id
      "Advance Request unapproved : #{self.money_request.name}"
    else
      "#{self.money_request.controlling_user.name} has unapproved the Advance Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if money_request.controlling_user.id == user.id
      "You have successfully unapproved the Advance Request : #{self.money_request.name}"
    else
      "#{self.money_request.controlling_user.name} has unapproved the Advance Request: #{self.money_request.name}"
    end
  end

end
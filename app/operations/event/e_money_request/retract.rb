class Event::EMoneyRequest::Retract < Event::EMoneyRequest::Base

  def event_id
    NotifierType.money_request_retract_id
  end

  def affected_users
    self.money_request.associated_users self.money_request.tracks.last.modified_user
  end

  def send_push_notification(user)
    return if user.id == money_request.controlling_user_id
    message = "#{self.money_request.user.name} retracted the Advance Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if user.id == money_request.user.id
      "Advance Request retracted : #{self.money_request.name}"
    else
      "#{money_request.user.name} has retracted the Advance Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.user.id
      "You have successfully retracted the Advance Request : #{self.money_request.name}"
    else
      "#{money_request.user.name} has retracted the Advance Request '#{self.money_request.name}'."
    end
  end

end

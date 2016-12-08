class Event::EMoneyRequest::TakeControl < Event::EMoneyRequest::Base

  def event_id
    NotifierType.money_request_take_control_id
  end

  def affected_users
    [self.money_request.controlling_user, self.money_request.controlling_for_user]
  end

  def send_push_notification(user)
    return if user.id == money_request.controlling_user_id
    message = "#{self.money_request.controlling_user.name} has taken control of the Advance Request : #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if user.id == money_request.controlling_user_id
      "You have taken control of the Advance Request: #{self.money_request.name}"
    else
      "#{self.money_request.controlling_user.name} has has taken control of the Advance Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.controlling_user_id
      "You have taken control of the Advance Request.<br/><br/>Advance Request: \"#{self.money_request.name}\""
    else
      "#{self.money_request.controlling_user.name} has has taken control of the Advance Request which was awaiting your review.<br/><br/>Advance Request: \"#{self.money_request.name}\""
    end
  end

end

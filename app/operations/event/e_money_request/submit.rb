class Event::EMoneyRequest::Submit < Event::EMoneyRequest::Base

  def event_id
    Event.money_request_submit_id
  end

  def affected_users
    [self.money_request.user, self.money_request.controlling_user]
  end

  def send_push_notification(user)
    return if user.id == money_request.user.id
    message = "#{self.money_request.user.name} has submitted the Advance Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)
  end

  def mailer_subject(user)
    if user.id == money_request.user.id
      "Advance Request submitted : #{self.money_request.name}"
    else
      "#{self.money_request.user.name} has submitted the Advance Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.user.id
      "Congratulations, you have successfully submitted the Advance Request: #{self.money_request.name}"
    else
      "#{self.money_request.user.name} has submitted the Advance Request: #{self.money_request.name} and is currently awaiting your approval"
    end
  end

end

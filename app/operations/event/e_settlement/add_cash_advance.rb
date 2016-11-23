class Event::ESettlement::AddCashAdvance < Event::ESettlement::Base

  def event_id
    Event.settlement_add_cash_advance_id
  end

  def send_push_notification(user)

  end

  def set_notification(user)

  end

  def mailer_subject(user)
    "You have received a cash advance of ₹#{payment.amount.value}"
  end

  def mailer_body(user)
    "This is to notify you that a cash advance of ₹#{payment.amount.value} has been recorded by #{payment.initiating_user.name}"
  end

end
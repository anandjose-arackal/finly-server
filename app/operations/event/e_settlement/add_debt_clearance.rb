class Event::ESettlement::AddDebtClearance < Event::ESettlement::Base

  def event_id
    Event.settlement_clear_debt_id
  end

  def send_push_notification(user)

  end

  def set_notification(user)

  end

  def mailer_subject(user)
    "Your payment of ₹#{payment.amount.value} back to the company has been recorded"
  end

  def mailer_body(user)
    "This is to notify you that your payment of ₹#{payment.amount.value} back to the company has been recorded"
  end

end
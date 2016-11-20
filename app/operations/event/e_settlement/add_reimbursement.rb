class Event::ESettlement::AddReimbursement < Event::ESettlement::Base

  def event_id
    Event.settlement_add_reimbursement_id
  end

  def send_push_notification(user)

  end

  def set_notification(user)

  end

  def mailer_subject(user)
    "A reimbursement of ₹#{payment.amount.value} has been processed"
  end

  def mailer_body(user)
    body = "This is to notify you that a reimbursement of ₹#{payment.amount.value} has been processed for the reports:<br>"
    i = 1
    self.payment.reports.each do |report|
      body += "<br>#{i}. #{report.name}"
      i += 1
    end
    body
  end

end
class Event::Settlement::AddAdvance < Event::Settlement::Base

  def event_id
    Event.settlement_add_advance_id
  end

  def send_push_notification(user)

  end

  def set_notification(user)

  end

  def mailer_subject(user)
    "You have received a cash advance of #{payment.amount.value}"
    # case payment.payment_type
    #   when PaymentType.advance_id
    #     return "You have received a cash advance of #{payment.amount.value}"
    #   when PaymentType.debt_clearance_id
    #     return "Cash payment of #{payment.amount.value} to #{user.company.name} has been recorded"
    #   when PaymentType.reimbursement_id
    #     return 'Congratulations! You have been reimbursed'
    #   when PaymentType.settlement_id
    #     return 'A settlement has been initiated against your cash in hand'
    #   else
    #     return nil
    # end
  end

  def mailer_body(user)
    "This is to notify you that a cash advance of #{payment.amount.value} has been recorded."
    # case payment.payment_type
    #   when PaymentType.advance_id
    #     return "This is to notify you that a cash advance of #{payment.amount.value} has been recorded."
    #   when PaymentType.debt_clearance_id
    #     return "This is to notify you that we have recorded a payment of #{payment.amount.value} to #{user.company.name}"
    #   when PaymentType.reimbursement_id
    #     message = "Congratulations! #{payment.initiating_user} has reimbursed the reports:"
    #     payment.reports.each do |report|
    #       message += "<br><br>#{report.name}"
    #     end
    #     return message
    #   when PaymentType.settlement_id
    #     message = 'This is to notify you that the pending reimbursements for the following reports have been settled against cash advance given by the company.<br><br>Reports:'
    #     payment.reports.each do |report|
    #       message += "<br>#{report.name}"
    #     end
    #     return message
    # end
  end
end
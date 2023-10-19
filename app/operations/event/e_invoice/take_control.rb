class Event::EInvoice::TakeControl < Event::EInvoice::Base
  def event_id
    NotifierType.id_for(:invoice_take_control)
  end

  def action_name
    'PO Invoice Taken Control of'
  end

  def affected_users
    invoice.affected_users(:take_control)
  end

  def notification_affected_users
    # invoice.notification_affected_users(:take_control)
    []
  end

  def mailer_subject(user)
    if user.id == last_action_user.id
      "You have taken control of the invoice: #{invoice.invoice_number}"
    else
      "#{last_action_user.name} has taken control of the invoice: #{invoice.invoice_number}"
    end
  end

  def mailer_body(user)
    if user.id == last_action_user.id
      "You have taken control of the invoice.<br/><br/>Invoice: \"#{invoice.invoice_number}\""
    else
      "#{last_action_user.name} has taken control of the invoice which was awaiting your review.<br/><br/>Invoice: \"#{invoice.invoice_number}\""
    end
  end
end

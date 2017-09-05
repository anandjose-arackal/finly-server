class Event::EBankPaymentRequest::Approve < Event::EBankPaymentRequest::Base

  attr_accessor :approving_user, :approved, :auto_approve

  def init
    super
    self.approving_user = self.bank_payment_request.bank_payment_request_trails.last.action_user
    self.approved = (self.bank_payment_request.approved? || self.bank_payment_request.closed?) ? true : false
    self.auto_approve = params[:approve]
  end


  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def affected_users
    if approved
      if auto_approve
        return [self.bank_payment_request.owner]
      end
      return [self.bank_payment_request.bank_payment_request_trails.last.action_user, self.bank_payment_request.owner]
    else
      [self.bank_payment_request.bank_payment_request_trails.last.action_user, self.bank_payment_request.controlling_user]
    end
  end

  def event_id

  end

  def set_notification(user)
    if approved
      if auto_approve
        notify_type = NotificationActionType.id_for(:notify_auto_approve)
      else
        notify_type = NotificationActionType.id_for(:notify_approve)
      end
    else
      notify_type = NotificationActionType.id_for(:notify_awaiting_approval)
    end
    view_role_id = bank_payment_request.controlling_user_role_id

  end

  def mailer_subject

  end

  def mailer_body

  end

end
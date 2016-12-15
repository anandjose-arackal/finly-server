class Event::EWallet::Credit < Event::EWallet::Base

  def event_id
    NotifierType.wallet_credit_id
  end

  def affected_users
    [self.payment.initiating_user, self.payment.receiving_user]
  end

  def notification_affected_users

  end

  def send_push_notification(user)
    return unless user.id == payment.receiving_user_id
    message = "You have received a credit of ₹#{payment.amount.value} in your #{to_account_s}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if user.id == self.payment.initiating_user_id
      "You have credited ₹#{self.payment.amount.value} to #{payment.receiving_user.name}'s #{to_account_s}"
    elsif user.id == self.payment.receiving_user_id
      "You have received a credit of ₹#{self.payment.amount.value} in your #{to_account_s}"
    end
  end

  def mailer_body(user)
    if user.id == self.payment.initiating_user_id
      "You have successfully credited ₹#{self.payment.amount.value} to #{payment.receiving_user.name}'s #{to_account_s}"
    elsif user.id == self.payment.receiving_user_id
      "You have received a credit of ₹#{self.payment.amount.value} from #{payment.initiating_user.name} in your #{to_account_s}"
    end
  end

end
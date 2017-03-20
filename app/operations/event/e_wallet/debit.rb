class Event::EWallet::Debit < Event::EWallet::Base

  def event_id
    NotifierType.id_for(:wallet_debit)
  end

  def affected_users
    [self.payment.initiating_user, self.payment.receiving_user]
  end

  def notification_affected_users
    [payment.receiving_user]
  end

  def send_push_notification(user)
    return unless user.id == payment.receiving_user_id
    message = "An amount of ₹#{self.payment.amount.value} has been debited from your #{from_account_s}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:wallet),
                                             action_type_id: NotificationActionType.id_for(:notify_debit),
                                             action_user_id: payment.initiating_user_id,
                                             object_id: payment.id,
                                             object_type: "Wallet",
                                             path_object_id: payment.id,
                                             path_object_type: "Wallet",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: nil,
                                             amount_attributes: {value: payment.amount_value,
                                                                 currency_id: 1
                                                                }
                                            )
    notification.save
  end

  def mailer_subject(user)
    if user.id == self.payment.initiating_user_id
      to_s = "your #{initiating_account_s}"
      if to_account == :virtual_account
        to_s = 'Company Credits'
      end
      "You have debited ₹#{self.payment.amount.value} from #{payment.receiving_user.name}'s #{receiving_account_s} to #{to_s}"
    elsif user.id == self.payment.receiving_user_id
      "An amount of ₹#{self.payment.amount.value} has been debited from your #{receiving_account_s}"
    end
  end

  def mailer_body(user)
    if user.id == self.payment.initiating_user_id
      to_s = "your #{initiating_account_s}"
      if to_account == :virtual_account
        to_s = 'Company Credits'
      end
      "You have successfully debited ₹#{self.payment.amount.value} from #{payment.receiving_user.name}'s #{receiving_account_s} to #{to_s}"
    elsif user.id == self.payment.receiving_user_id
      "An amount of ₹#{self.payment.amount.value} has been debited from your #{receiving_account_s} by #{payment.initiating_user.name}"
    end
  end

end

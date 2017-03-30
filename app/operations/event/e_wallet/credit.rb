class Event::EWallet::Credit < Event::EWallet::Base

  def event_id
    NotifierType.id_for(:wallet_credit)
  end

  def action_name
    "Credit Processed"
  end

  def affected_users
    [self.payment.initiating_user, self.payment.receiving_user]
  end

  def notification_affected_users
    [payment.receiving_user]
  end

  def send_push_notification(user)
    return unless user.id == payment.receiving_user_id
    message = "You have received a credit of ₹#{payment.amount.value} in your #{to_account_s}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    case to_account
      when :wallet
        object = "Wallet"
      when :card
        object = "Card"
      else
        object = "Wallet"
    end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:wallet),
                                             action_type_id: NotificationActionType.id_for(:notify_credit),
                                             action_user_id: payment.initiating_user_id,
                                             object_id: payment.id,
                                             object_type: object,
                                             path_object_id: payment.id,
                                             path_object_type: object,
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
      from_s = "your #{from_account_s}"
      if to_account == :virtual_account
        from_s = 'Company Credits'
      end
      "You have credited ₹#{self.payment.amount.value} to #{payment.receiving_user.name}'s #{to_account_s} from #{from_s}"
    elsif user.id == self.payment.receiving_user_id
      "You have received a credit of ₹#{self.payment.amount.value} in your #{to_account_s}"
    end
  end

  def mailer_body(user)
    if user.id == self.payment.initiating_user_id
      from_s = "your #{from_account_s}"
      if to_account == :virtual_account
        from_s = 'Company Credits'
      end
      "You have successfully credited ₹#{self.payment.amount.value} to #{payment.receiving_user.name}'s #{to_account_s} from #{from_s}"
    elsif user.id == self.payment.receiving_user_id
      "You have received a credit of ₹#{self.payment.amount.value} from #{payment.initiating_user.name} in your #{to_account_s}"
    end
  end

  def set_presenter_params
    super
    params[:payment_note] = payment.note
  end

end

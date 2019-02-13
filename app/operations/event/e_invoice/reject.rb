class Event::EInvoice::Reject < Event::EInvoice::Base
  attr_accessor :rejecting_user

  def init
    super
    self.rejecting_user = self.invoice.trails.last.action_user rescue nil
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:invoice_reject)
  end

  def action_name
    'Invoice Rejected'
  end

  def affected_users
    # User::AssociatedUsers::Index.(self.user, document: self.invoice, user_before: self.user, amount: invoice.net_amount.value)
    self.invoice.affected_users(:reject)
  end

  # def get_token(user)
  #   email_authorization = params[:email_authorization]
  #   email_authorization.token
  # end


  def notification_affected_users
    # self.controlling_users
    self.invoice.notification_affected_users(:reject)
  end

  # def send_push_notification(user)
  #   return if user.id == report.user.id
  #   message = "#{self.report.user.name} has submitted the report: #{self.report.name}"
  #   view = UserRole.name_for(report.controlling_user_role_id)
  #   GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  # end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:invoice),
                                             action_type_id: NotificationActionType.id_for(:notify_reject),
                                             action_user_id: invoice.trails.last.action_user_id,
                                             object_id: invoice.id,
                                             object_type: "Invoice",
                                             path_object_id: invoice.id,
                                             path_object_type: "Invoice",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user == self.rejecting_user
      "You rejected the invoice : #{self.invoice.invoice_number}"
    else
      "#{rejecting_user.name} has rejected the invoice: #{self.invoice.invoice_number}"
    end
  end

  def mailer_body(user)
    if user == self.rejecting_user
      "You have rejected the invoice: #{self.invoice.invoice_number}"
    else
      "#{self.rejecting_user.name} has rejected the invoice: #{self.invoice.invoice_number}"
    end
  end

  def report_view_role(user)
    # if user.id == report.user_id
    #   return nil
    # elsif user.id == report.controlling_user_id
    #   return report.controlling_user_role_id
    # end
    invoice.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end
end

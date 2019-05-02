class Event::EVendors::Reject < Event::EVendors::Base
  attr_accessor :rejecting_user, :roles

  def init
    super
    self.rejecting_user = self.document.trails.last.action_user rescue nil
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:vendor_reject)
  end

  def action_name
    "Vendor Rejected"
  end

  def affected_users
    self.document.affected_users(:reject)
  end

  def set_notification(user)
    # self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    notification = user.notifications.build(user: user,
                                            notification_type_id: NotificationType.id_for(:vendor),
                                            action_type_id: NotificationActionType.id_for(:notify_reject),
                                            action_user_id: document.trails.last.action_user.id,
                                            object_id: document.id,
                                            object_type: "YesBankVendor",
                                            path_object_id: document.id,
                                            path_object_type: "YesBankVendor",
                                            read: false,
                                            timestamp: DateUtils.local_date_time,
                                            view_role_id: role_id,
                                            application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user == self.rejecting_user
      "You rejected the Vendor : #{self.document.business_name}"
    else
      "#{rejecting_user.name} has rejected the Vendor: #{self.document.business_name}"
    end
  end

  def mailer_body(user)
    if user == self.rejecting_user
      "You have rejected the Vendor : #{self.document.business_name}"
    else
      "#{rejecting_user.name} has rejected the Vendor: '#{self.document.business_name}'"
    end
  end
end
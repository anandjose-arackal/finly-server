class Event::EPurchaseRequest::Unapprove < Event::EPurchaseRequest::Base
  attr_accessor :approved, :approving_user, :auto_approve

  def action_name
    'Purchase request Unapproved'
  end

  def init
    super
    self.approving_user = self.purchase_request.trails&.last&.action_user
  end

  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_request_unapprove)
  end

  def affected_users
    self.purchase_request.affected_users(:unapprove)
  end

  def notification_affected_users
    self.purchase_request.notification_affected_users(:unapprove)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_request),
                                             action_type_id: NotificationActionType.id_for(:notify_unapprove),
                                             action_user_id: (purchase_request.creator_id),
                                             object_id: purchase_request.id,
                                             object_type: "PurchaseRequest",
                                             path_object_id: purchase_request.id,
                                             path_object_type: "PurchaseRequest",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    if purchase_request.get_reviewers.include? user
      "Purchase Request unapproved : #{purchase_request.order_number}"
    else
      "#{self.purchase_request.trails.last.action_user.name} has unapproved the purchase request: #{purchase_request.order_number}"
    end
  end

  def mailer_body(user)
    if purchase_request.get_reviewers.include? user
      "You have successfully unapproved the purchase_request : #{self.purchase_request.order_number}"
    else
      "#{self.purchase_request.trails.last.action_user.name} has unapproved the purchase request: #{self.purchase_request.order_number}"
    end
  end
end

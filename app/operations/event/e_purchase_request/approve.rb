class Event::EPurchaseRequest::Approve < Event::EPurchaseRequest::Base
  attr_accessor :approving_user, :po_initiators

  def init
    super
    self.approving_user = self.purchase_request.trails.last.action_user rescue nil
  end

  def validate
    super
    unless self.approving_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_request_approve)
  end

  def action_name
    'Purchase Request approved'
  end

  def affected_users
    if purchase_request.approved? && purchase_request.company.configuration.email_purchase_order_initiator
      # If PR is approved, send email to all PO initiators in that policy
      po_initiators_in_pr_policy = purchase_request.policy.policy_user_roles.where(user_role_id: UserRole.id_for(:purchase_order_initiator)).pluck(:user_id) rescue []
      self.po_initiators = user.company.users.where(id: po_initiators_in_pr_policy)
      self.purchase_request.affected_users(:approve) + po_initiators
    else
      self.purchase_request.affected_users(:approve)
    end
  end

  def notification_affected_users
    self.purchase_request.notification_affected_users(:approve)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_request),
                                             action_type_id: NotificationActionType.id_for(:notify_approve),
                                             action_user_id: purchase_request.creator_id,
                                             object_id: purchase_request.id,
                                             object_type: "PurchaseRequest",
                                             path_object_id: purchase_request.id,
                                             path_object_type: "PurchaseRequest",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user == self.approving_user
      "You approved the purchase request : #{self.purchase_request.order_number}"
    elsif po_initiators.present? && po_initiators.include?(user)
      "#{approving_user.name} has approved the purchase request: #{self.purchase_request.order_number} and is awaiting your action in approved items"
    else
      "#{approving_user.name} has approved the purchase request: #{self.purchase_request.order_number}"
    end
  end

  def mailer_body(user)
    # i.e. this is the user who approved the PR
    if user == self.approving_user
      "You have approved the purchase request: #{self.purchase_request.order_number}"
      # i.e. the PR is approved and is awaiting the initiators to create a PO from it
    elsif po_initiators.present? && po_initiators.include?(user)
      "#{approving_user.name} has approved the purchase request: #{self.purchase_request.order_number} and is awaiting your action in approved items"
      # now the PR hasn't been approved yet and is waiting someone else's approval
    else
      "#{self.approving_user.name} has approved the purchase request: #{self.purchase_request.order_number} and is awaiting your further approval"
    end
  end

end

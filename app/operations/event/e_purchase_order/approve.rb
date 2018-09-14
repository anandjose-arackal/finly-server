class Event::EPurchaseOrder::Approve < Event::EPurchaseOrder::Base
  attr_accessor :approved, :approving_user, :auto_approve,
                :controlling_users

  def action_name
    'Purchase Order Approved'
  end

  def init
    super
    self.approving_user = self.purchase_order.trails.natural_order.last.action_user
    self.approved = (purchase_order.approved? or purchase_order.closed?) if purchase_order.present?
    #todo add it to params
    self.auto_approve = params[:auto_approve]

    # Get controlling users
    controlling_level = self.purchase_order.level
    if controlling_level.present?
      amount = purchase_order.balance_amount&.value || 0
      controlling_user_ids = controlling_level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)
      self.controlling_users = User.with_id(controlling_user_ids).with_company_id(self.user.company_id)
    else
      self.controlling_users = []
    end
  end

  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_order_approve)
  end

  def affected_users
    if approved
      if auto_approve
        return [self.purchase_order.user]
      end
      [self.purchase_order.trails.last.action_user, self.purchase_order.user]
    else
      users = [self.purchase_order.trails.last.action_user]
      if controlling_users.present?
        controlling_users.each do |user|
          users.push(user)
        end
      end
      users
    end
  end

  def notification_affected_users
    if approved
      [purchase_order.user]
    else
      self.controlling_users
    end
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
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: notify_type,
                                             action_user_id: (purchase_order.trails.last.action_user.id rescue nil),
                                             object_id: purchase_order.id,
                                             object_type: "Purchase Order",
                                             path_object_id: purchase_order.id,
                                             path_object_type: "Purchase Order",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    approver_id = self.purchase_order.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      "Purchase Order approved : #{self.purchase_order.po_number}"
    else
      if approved and user.id == self.purchase_order.user.id
        if auto_approve
          return "Congratulations! Your purchase order #{purchase_order.po_number} has been auto-approved"
        else
          return "Congratulations! Your purchase order #{purchase_order.po_number} has been approved"
        end
      else
        "#{approving_user.name} has approved the purchase order: #{self.purchase_order.po_number}"
      end
    end
  end

  def mailer_body(user)
    approver_id = self.purchase_order.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      message = "You have successfully approved the purchase order : #{self.purchase_order.po_number}"
    else
      if approved and user.id == purchase_order.user.id
        if auto_approve
          message = "Congratulations! Your purchase order #{purchase_order.po_number} has been auto-approved"
        else
          message = "Congratulations! Your purchase order #{purchase_order.po_number} has been approved"
        end
      else
        message = "#{approving_user.name} has approved the purchase order '#{self.purchase_order.po_number}' and is currently waiting for your approval"
      end
    end
    message
  end

end

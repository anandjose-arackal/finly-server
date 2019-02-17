class Event::EPurchaseOrder::Approve < Event::EPurchaseOrder::Base
  attr_accessor :approved, :approving_user, :auto_approve,
                :controlling_users

  def action_name
    'Purchase Order Approved'
  end

  def init
    super
    self.approving_user = self.purchase_order.trails.last.action_user
    self.approved = (purchase_order.approved? || purchase_order.closed? || purchase_order.auto_approved?) if purchase_order.present?
    self.auto_approve = params[:auto_approve]

    self.controlling_users = []

    # Get controlling users
    level = self.purchase_order.level


    if level.present?
      amount = purchase_order.balance_amount&.value || 0

      # Find list of possible controlling user ids
      controlling_users_ids = level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)

      user_selected_reviewer = purchase_order.document_level_reviewer_mappings.with_level_ids(level.id).last&.reviewer
      if user_selected_reviewer.present? && controlling_users_ids.include?(user_selected_reviewer.id)
      # Check if user selected reviewer is satisfies level reviewer mapping threshold criteria
        self.controlling_users.push user_selected_reviewer
      else
        # User selected reviewer is not present in list of users satisfying current level's threshold criteria
        # select all the threshold satifying reviewers
        user.company.users.with_id(controlling_users_ids).each do |user|
          self.controlling_users.push(user)
        end
      end
    else
      controlling_users = []
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
    # if approved
    #   if auto_approve
    #     return [self.purchase_order.user]
    #   end
    #   [self.purchase_order.trails.last.action_user, self.purchase_order.user]
    # else
    #   users = [self.purchase_order.trails.last.action_user]
    #   if controlling_users.present?
    #     controlling_users.each do |user|
    #       users.push(user)
    #     end
    #   end
    #   users
    # end
    purchase_order.document_role_users(:creditor).present? ? ( self.purchase_order.affected_users(:approve) + purchase_order.document_role_users(:creditor) ) :  self.purchase_order.affected_users(:approve)
  end

  def notification_affected_users
    # if approved
    #   [purchase_order.user]
    # else
    #   self.controlling_users
    # end
    self.purchase_order.notification_affected_users(:approve)
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
                                             action_user_id: (purchase_order.trails.last.action_user_id rescue nil),
                                             object_id: purchase_order.id,
                                             object_type: "Purchase Order",
                                             path_object_id: purchase_order.id,
                                             path_object_type: "Purchase Order",
                                             read: false,
                                             timestamp: DateUtils,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    if self.approving_user.present? and user.id == self.approving_user.id
      "Purchase Order approved : #{self.purchase_order.po_number}"
    else
      if approved 
        if user.id == self.purchase_order.user.id
          if auto_approve
            return "Congratulations! Your purchase order #{purchase_order.po_number} has been auto-approved"
          else
            return "Congratulations! Your purchase order #{purchase_order.po_number} has been approved"
          end
        elsif self.purchase_order.document_role_users(:creditor).include?(user)
         "#{approving_user.name} has approved the purchase order: #{self.purchase_order.po_number} and is waiting for your approval"   
        end
      elsif self.purchase_order.document_role_users(:creditor).include?(user)
         "#{approving_user.name} has approved the purchase order: #{self.purchase_order.po_number} and is waiting for your approval"
      else
        "#{approving_user.name} has approved the purchase order: #{self.purchase_order.po_number}"
      end
    end
  end

  def mailer_body(user)
    if self.approving_user.present? and user.id == self.approving_user.id
      message = "You have successfully approved the purchase order : #{self.purchase_order.po_number}"
    else
      if approved 
        if user.id == purchase_order.user.id
          if auto_approve
            message = "Congratulations! Your purchase order #{purchase_order.po_number} has been auto-approved"
          else
            message = "Congratulations! Your purchase order #{purchase_order.po_number} has been approved"
          end
        elsif self.purchase_order.document_role_users(:creditor).include?(user)
         "#{approving_user.name} has approved the purchase order: #{self.purchase_order.po_number} and is waiting for your approval"
        end
      elsif self.purchase_order.document_role_users(:creditor).include?(user)
         "#{approving_user.name} has approved the purchase order: #{self.purchase_order.po_number} and is waiting for your approval"
      else
        message = "#{approving_user.name} has approved the purchase order '#{self.purchase_order.po_number}' and is currently waiting for your approval"
      end
    end
    message
  end
end

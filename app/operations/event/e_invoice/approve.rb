class Event::EInvoice::Approve < Event::EInvoice::Base
  attr_accessor :approved, :approving_user, :auto_approve,
                :controlling_users

  def action_name
    'Invoice Approved'
  end

  def init
    super
    self.approving_user = self.invoice.trails.last.action_user
    self.approved = (invoice.approved? or invoice.closed?) if invoice.present?
    #todo add it to params
    self.auto_approve = params[:auto_approve]

    # Get controlling users
    controlling_level = self.invoice.level
    if controlling_level.present?
      amount = invoice.net_amount&.value || 0
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
    NotifierType.id_for(:invoice_approve)
  end

  def affected_users
    if approved
      if auto_approve
        return [self.invoice.created_by]
      end
      [self.invoice.trails.last.action_user, self.invoice.created_by]
    else
      users = [self.invoice.trails.last.action_user]
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
      [invoice.created_by]
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
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:invoice),
                                             action_type_id: notify_type,
                                             action_user_id: (invoice.trails.last.action_user.id rescue nil),
                                             object_id: invoice.id,
                                             object_type: "Invoice",
                                             path_object_id: invoice.id,
                                             path_object_type: "Invoice",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    if self.approving_user.present? && user.id == self.approving_user.id
      "Invoice approved : #{self.invoice.invoice_number}"
    else
      if approved and user.id == self.invoice.created_by.id
        if auto_approve
          return "Congratulations! Your invoice #{invoice.invoice_number} has been auto-approved"
        else
          return "Congratulations! Your invoice #{invoice.invoice_number} has been approved"
        end
      else
        "#{approving_user.name} has approved the invoice: #{self.invoice.invoice_number}"
      end
    end
  end

  def mailer_body(user)
    if self.approving_user.present? && user.id == self.approving_user.id
      message = "You have successfully approved the invoice : #{self.invoice.invoice_number}"
    else
      if approved and user.id == invoice.created_by.id
        if auto_approve
          message = "Congratulations! Your invoice #{invoice.invoice_number} has been auto-approved"
        else
          message = "Congratulations! Your invoice #{invoice.invoice_number} has been approved"
        end
      else
        message = "#{approving_user.name} has approved the invoice '#{self.invoice.invoice_number}' and is currently waiting for your approval"
      end
    end
    message
  end

end

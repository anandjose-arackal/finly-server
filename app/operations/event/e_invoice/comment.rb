class Event::EInvoice::Comment < Event::EInvoice::Base
  attr_accessor :document

  def init
    super
    self.document = params[:document]
  end

  def validate
    if self.document.blank?
      add_message :error, "Document not found"
      return
    end
  end

  def event_id
    NotifierType.id_for(:invoice_comment)
  end

  def action_name
    'Invoice has a Comment'
  end

  def affected_users
    ( self.document.affected_users(:approve) + self.document.affected_users(:reject) + self.document.affected_users(:take_control) + self.document.affected_users(:forwarded) + self.document.affected_users(:unapprove) + self.document.affected_users(:comment) ).uniq
  end

  def notification_affected_users
    # self.document.notification_affected_users(:approve)
    ( self.document.affected_users(:approve) + self.document.affected_users(:reject) + self.document.affected_users(:take_control) + self.document.affected_users(:forwarded) + self.document.affected_users(:unapprove) + self.document.affected_users(:comment) ).uniq
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:invoice),
                                             action_type_id: NotificationActionType.id_for(:notify_comment),
                                             action_user_id: current_action_user&.id,
                                             object_id: document.id,
                                             object_type: "Invoice",
                                             path_object_id: document.id,
                                             path_object_type: "Invoice",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if current_action_user == self.document.created_by
      "New Comment on Invoice : #{self.document.invoice_number}"
    else
      "#{current_action_user.name} has added a new comment to the invoice: #{self.document.invoice_number}"
    end
  end

  def mailer_body(user)
    if current_action_user == self.document.created_by
      "New Comment on Invoice: #{self.document.invoice_number} (Invoice ID: #{self.document.invoice_id}) \n Comment: #{self.document.comments.last.body}"
    else
      "#{current_action_user.name} has added a new comment to the invoice: #{self.document.invoice_number} (Invoice ID: #{self.document.invoice_id}) \n Comment: #{self.document.comments.last.body}"
    end
  end

  def current_action_user
    RequestStore.store[:current_user]
  end

end

class Event::EInvoice::Submit < Event::EInvoice::Base
  def event_id
    NotifierType.id_for(:invoice_submit)
  end

  def action_name
    'Invoice Submitted'
  end

  def affected_users
    # [self.report.user, self.report.reload.controlling_user]
    users = []
    users.push self.invoice.created_by

    level = ReviewalLevel.find_by id: workflow_output[:modified_level_id]

    if level.present?
      user_selected_reviewer = invoice.document_level_reviewer_mappings.with_level_ids(level.id).last
      if user_selected_reviewer.present?
        self.controlling_users.push(user_selected_reviewer.reviewer)
        users.push(user_selected_reviewer.reviewer)
      else
        amount = invoice.net_amount.value
        reviewers_ids = level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)
        reviewers = User.with_id(reviewers_ids)
        reviewers.each do |reviewer|
          users.push(reviewer)
          self.controlling_users.push(reviewer)
        end
      end
    end
    users
  end

  # def get_token(user)
  #   email_authorization = params[:email_authorization]
  #   email_authorization.token
  # end


  def notification_affected_users
    self.controlling_users
  end

  # def send_push_notification(user)
  #   return if user.id == report.user.id
  #   message = "#{self.report.user.name} has submitted the report: #{self.report.name}"
  #   view = UserRole.name_for(report.controlling_user_role_id)
  #   GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  # end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:invoice),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
                                             action_user_id: invoice.created_by.id,
                                             object_id: invoice.id,
                                             object_type: "Invoice",
                                             path_object_id: invoice.id,
                                             path_object_type: "Invoice",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: role_id
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == invoice.created_by.id
      "Invoice submitted : #{self.invoice.invoice_number}"
    else
      "#{self.invoice.created_by.name} has submitted Invoice : #{self.invoice.invoice_number}"
    end
  end

  def mailer_body(user)
    if user.id == invoice.created_by.id
      "Congratulations, you have successfully submitted the invoice : #{self.invoice.invoice_number}"
    else
      "#{self.invoice.created_by.name} has submitted invoice: #{self.invoice.invoice_number} and is currently awaiting your approval."
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

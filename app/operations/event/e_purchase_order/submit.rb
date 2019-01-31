class Event::EPurchaseOrder::Submit < Event::EPurchaseOrder::Base
  def event_id
    NotifierType.id_for(:purchase_order_submit)
  end

  def action_name
    'Purchase Order Submitted'
  end

  def affected_users
    # [self.report.user, self.report.reload.controlling_user]
    # users = []
    # users.push self.purchase_order.user

    # level = ReviewalLevel.find_by id: workflow_output[:modified_level_id]

    # if level.present?
    #   user_selected_reviewer = purchase_order.document_level_reviewer_mappings.with_level_ids(level.id).last
    #   if user_selected_reviewer.present?
    #     self.controlling_users.push(user_selected_reviewer.reviewer)
    #     users.push(user_selected_reviewer.reviewer)
    #   else
    #     amount = purchase_order.balance_amount.value
    #     reviewers_ids = level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id)
    #     reviewers = User.with_id(reviewers_ids)
    #     reviewers.each do |reviewer|
    #       users.push(reviewer)
    #       self.controlling_users.push(reviewer)
    #     end
    #   end
    # end
    # users
    self.purchase_order.affected_users(:submit)
  end

  # def get_token(user)
  #   email_authorization = params[:email_authorization]
  #   email_authorization.token
  # end


  def notification_affected_users
    self.purchase_order.notification_affected_users(:submit)
  end

  # def send_push_notification(user)
  #   return if user.id == report.user.id
  #   message = "#{self.report.user.name} has submitted the report: #{self.report.name}"
  #   view = UserRole.name_for(report.controlling_user_role_id)
  #   GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  # end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
                                             action_user_id: purchase_order.user_id,
                                             object_id: purchase_order.id,
                                             object_type: "Purchase Order",
                                             path_object_id: purchase_order.id,
                                             path_object_type: "Purchase Order",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == purchase_order.user.id
      "Purchase Order submitted : #{self.purchase_order.po_number}"
    else
      "#{self.purchase_order.user.name} has submitted Purchase Order : #{self.purchase_order.po_number}"
    end
  end

  def mailer_body(user)
    if user.id == purchase_order.user.id
      "Congratulations, you have successfully submitted the purchase order : #{self.purchase_order.po_number}"
    else
      "#{self.purchase_order.user.name} has submitted purchase order: #{self.purchase_order.po_number} and is currently awaiting your approval."
    end
  end

  # def report_view_role(user)
  #   if user.id == report.user_id
  #     return nil
  #   elsif user.id == report.controlling_user_id
  #     return report.controlling_user_role_id
  #   end
  # end
end

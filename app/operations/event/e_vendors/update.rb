class Event::EVendors::Update < Event::EVendors::Base

  def event_id
    NotifierType.id_for(:vendor_update)
  end

  def action_name
    "Vendor Details Updated"
  end

  def affected_users
    # [self.bank_payment_request.owner, self.bank_payment_request.reload.controlling_user]
    self.document.affected_users(:approve)
  end


  def notification_affected_users
    self.document.notification_affected_users(:approve)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:vendor),
                                             action_type_id: NotificationActionType.id_for(:notify_update),
                                             action_user_id: document.created_by_id,
                                             object_id: document.id,
                                             object_type: "YesBankVendor",
                                             path_object_id: document.id,
                                             path_object_type: "YesBankVendor",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             # view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    "Vendor details updated for: #{self.document.business_name}"
  end

  def mailer_body(user)
    message = "Vendor details for #{self.document.business_name} were updated by #{user.name} <br><br>"

    if params[:vendor_changes].present?

      message += "These were the changes: <br>"

      # start bank account was changed
      if params[:vendor_changes][:bank_account_changed].present?
        params[:vendor_changes][:bank_accounts].each do |bank_account|
          next if bank_account.blank?
          message += "-----<br>"
          if bank_account[:name].present?
            message += "Old Name - #{bank_account[:name].first}<br>"
            message += "New Name - #{bank_account[:name].last}<br>"
          end

          if bank_account[:account_number].present?
            message += "Old Account Number - #{bank_account[:account_number].first}<br>"
            message += "New Account Number - #{bank_account[:account_number].last}<br>"
          end

          if bank_account[:ifsc].present?
            message += "Old IFSC - #{bank_account[:ifsc].first}<br>"
            message += "New IFSC - #{bank_account[:ifsc].last}<br>"
          end
        end
      end
      # end bank_account changes

    end # END vendor_changes

    message
  end
end

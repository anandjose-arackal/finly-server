class Notifier::Mailer < Notifier::API

  processor self


  def send_mail?(current_user, params)
    ########################################
    # Logic for fetching notification config
    # ######################################
    # if current_user.notification_configs.present? && current_user.notification_config.
    #   true
    # elsif current_user.company.notification_configs.present? && current_user.company.notification_configs.with_action(action_id).with_document(document).first.mail == true
    #   true
    # end
    true
  end

  def dispatch(options, current_user:, params:, **)
    # recipients =  self.class.recipient_users.present? ? self.class.recipient_users[:values] : self.class.recipient_users[:block].call(current_user, params)
    recipients = self.class.recipient_users.is_a?(Proc) ? self.class.recipient_users.call(current_user, params) : self.class.recipient_users

    recipients.each do |recipient|
      params[:recipient] = recipient
      if send_mail?(recipient, params)
        payload = process_params(recipient, params)
        DocumentMailer.dispatch(payload)
      end
    end
  end
end
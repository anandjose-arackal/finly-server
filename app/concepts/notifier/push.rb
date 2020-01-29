class Notifier::Push < Notifier::API

  processor self

  def process_params(current_user, params)
    new_payload = {}
    self.class.payload.each do |key, value|
      if value[:value].present?
        new_payload[key] = value[:value]
      elsif value[:block].present?
        new_payload[key] = value[:block].call(current_user, params)
      end
    end
    new_payload
  end

  def send_mail?(options, current_user:, params:, **)
    ########################################
    # Logic for fetching notification config
    # ######################################
    # if current_user.notification_configs.present? && current_user.notification_config.
    #   true
    # elsif current_user.company.notification_configs.present? && current_user.company.notification_configs.with_action(action_id).with_document(document).first.mail == true
    #   true
    # end
    false
  end

  def dispatch(options, current_user:, params:, **)
    if send_mail?
      payload = process_params(current_user, params)
      DocumentMailer.dispatch(payload)
    end
  end
end
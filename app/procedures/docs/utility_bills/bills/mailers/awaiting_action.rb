class Docs::UtilityBills::Bills::Mailers::AwaitingApproval < Notifier::Mailer

  # def self.event(event_name)
  #   consumes_event! 'bbps_bill.submit'
  # end
  #
  # def permissions(options, current_user:, params:, **)
  #   ########################################
  #   # Logic for fetching notification config
  #   # ######################################
  #   # if current_user.notification_configs.present? && current_user.notification_config.
  #   #   true
  #   # elsif current_user.company.notification_configs.present? && current_user.company.notification_configs.with_action(action_id).with_document(document).first.mail == true
  #   #   true
  #   # end
  # end
  #
  # set :to, -> (user, params) {params[:target_user]&.email}
  # set :template, "bbps/bill_mailer"
  # set :subject, "Bill has been submitted!"
  # set :cc do |params|
  #   params[:user].email
  # end

end
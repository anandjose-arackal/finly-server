# Used for setting notifications. Automatically handles user configuration as well to
# ensure push and mailer notifications are sent only if its configured by the user
class Event::EAdmin::AdminSetNotifier < Event::SetNotifier

  def user_model
    AdminUser
  end

end

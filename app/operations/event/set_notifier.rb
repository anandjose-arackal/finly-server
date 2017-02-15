# Used for setting notifications. Automatically handles user configuration as well to
# ensure push and mailer notifications are sent only if its configured by the user
class Event::SetNotifier < Event::Base
  attr_accessor :event_obj, :has_push_notification, :has_mailer

  def event_id

  end

  def affected_users

  end

  def push_notification_affected_users
    affected_users
  end

  def mailer_affected_users
    affected_users
  end

  def notification_affected_users
    affected_users
  end

  def send_push_notification(user)

  end

  def send_mailer(user)

  end

  def set_notification(user, role = nil)

  end

  def process
    # todo - have to ensure *_affected_users always returns an array of users

    # sending mailers
    users = mailer_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? or not user.is_a?(User)
        user_event_configuration = load_configuration(user)
        if allow_mailer(user, user_event_configuration)
          send_mailer(user)
        end
      end
    end

    # sending push notifications
    users = push_notification_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? or not user.is_a?(User)
        user_event_configuration = load_configuration(user)
        if allow_push_notification(user, user_event_configuration)
          send_push_notification(user)
        end
      end
    end

    # sending notifications
    users = notification_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? or not user.is_a?(User)
        set_notification(user)
      end
    end
  end

  def event
    return self.event_obj if self.event_obj.present?
    self.event_obj = NotifierType.find_by(id: event_id) if event_id.present?
    event_obj
  end

  def has_mailer?
    return has_mailer if has_mailer.present?
    event = self.event
    if event.blank? or event.has_mailer
      has_mailer = true
    else
      has_mailer = false
    end
    has_mailer
  end

  def has_push_notification?
    return has_push_notification if has_push_notification.present?
    event = self.event
    if event.blank? or event.has_push_notification
      has_push_notification = true
    else
      has_push_notification = false
    end
    has_push_notification
  end

  def load_configuration(user)
    return nil if user.blank?
    user.notifier_type_configurations.with_event(event_id).first rescue nil
  end

  def allow_mailer(user, configuration)
    event = self.event
    # debugger
    return false unless has_mailer?
    return false if user.blank? or not user.is_a?(User)
    return false unless event.configurable_mailer
    return configuration.allow_mailer if configuration.present?
    true
  end

  def allow_push_notification(user, configuration)
    event = self.event
    return false unless has_push_notification?
    return false if user.blank? or not user.is_a?(User)
    return false unless event.configurable_push_notification
    return configuration.allow_push_notification if configuration.present?
    true
  end

  class MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    def validate
    end

    def to
    end

    def subject
    end

    def body
    end

  end

end

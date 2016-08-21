class Event::Base < BaseOperation
  attr_accessor :event_obj, :has_push_notification, :has_mailer

  def event_id

  end

  def affected_users

  end

  def send_push_notification(user, gcm_sender_id)

  end

  def send_mailer(user)

  end

  def set_notification(user)

  end

  def process
    users = affected_users
    return if users.blank?
    users.each do |user|
      next if user.blank? or not user.is_a?(User)
      user_event_configuration = load_configuration(user)
      if allow_push_notification(user_event_configuration) and user.profile.gcm_sender_id.present?
        send_push_notification(user, user.profile.gcm_sender_id)
      end
      if allow_mailer(user_event_configuration)
        send_mailer(user)
      end
      set_notification(user)
    end
  end

  def event
    return self.event_obj if self.event_obj.present?
    self.event_obj = Event.find_by(id: event_id) if event_id.present?
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
    user.event_configurations.with_event(event_id).first rescue nil
  end

  def allow_mailer(configuration)
    event = self.event
    return false unless has_mailer?
    return false if user.blank? or not user.is_a?(User)
    return false unless event.configurable_mailer
    return configuration.allow_mailer if configuration.present?
    true
  end

  def allow_push_notification(configuration)
    event = self.event
    return false unless has_push_notification?
    return false if user.blank? or not user.is_a?(User)
    return false unless event.configurable_push_notification
    return configuration.allow_push_notification if configuration.present?
    true
  end

end
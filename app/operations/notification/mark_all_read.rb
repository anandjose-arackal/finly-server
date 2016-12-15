class Notification::MarkAllRead < Notification::Base

  attr_accessor :notifications

  def pre_validate
    if user.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.notifications = user.notifications
  end

  def process
    unless notifications.update_all(read: true)
      add_message :error, "Failed. PLease try again"
    end
  end

  def success
    {success: true}
  end

  def failure
    {success: false}
  end

end
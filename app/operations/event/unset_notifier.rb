# Used to unset notifiers (mailers, push notifications and notifications) when the respective page is opened
class Event::UnsetNotifier < Event::Base

  attr_accessor :notification

  def init
    self.notification = user.notifications.find_by(id: params[:n_id])
  end

  def process
    notification.update_attributes(read: true)
  end

end
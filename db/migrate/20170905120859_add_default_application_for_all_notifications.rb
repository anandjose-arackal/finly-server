class AddDefaultApplicationForAllNotifications < ActiveRecord::Migration[4.2]
  def change
    Notification.all.update_all(application: "em")
  end
end

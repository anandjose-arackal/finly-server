class AddDefaultApplicationForAllNotifications < ActiveRecord::Migration
  def change
    Notification.all.update_all(application: "em")
  end
end

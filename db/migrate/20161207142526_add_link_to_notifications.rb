class AddLinkToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :link, :text
  end
end

class AddApplicationToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :application, :string
  end
end

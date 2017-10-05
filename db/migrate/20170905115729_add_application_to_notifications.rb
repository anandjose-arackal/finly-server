class AddApplicationToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :application, :string
  end
end

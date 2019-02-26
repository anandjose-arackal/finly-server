class AddIncompleteToUserDeviceBrowsers < ActiveRecord::Migration[5.2]
  def change
    add_column :user_device_browsers, :incomplete, :boolean, index: true
  end
end

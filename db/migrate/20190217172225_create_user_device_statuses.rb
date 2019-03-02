class CreateUserDeviceStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_device_statuses do |t|
      t.string :name, index: true, null: false

      t.timestamps
    end
    UserDeviceStatus.seed_data
  end
end

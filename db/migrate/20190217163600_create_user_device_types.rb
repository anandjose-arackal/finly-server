class CreateUserDeviceTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :user_device_types do |t|
      t.string :name, index: true, null: false

      t.timestamps
    end
    UserDeviceType.seed_data
  end
end

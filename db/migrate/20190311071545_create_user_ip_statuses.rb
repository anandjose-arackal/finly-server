class CreateUserIpStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_ip_statuses do |t|
      t.string :name, index: true, null: false

      t.timestamps
    end
    UserIpStatus.seed_data
  end
end

class CreateUserSessionStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_session_statuses do |t|
      t.string :name, index: true, null: false

      t.timestamps
    end
    UserSessionStatus.seed_data
  end
end

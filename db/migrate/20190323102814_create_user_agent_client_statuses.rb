class CreateUserAgentClientStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_agent_client_statuses do |t|
      t.string :name, null: false, index: true

      t.timestamps
    end
    UserAgentClientStatus.seed_data
  end
end

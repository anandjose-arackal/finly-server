class CreateUserMailerConfigurations < ActiveRecord::Migration
  def change
    create_table :user_mailer_configurations do |t|

      t.timestamps null: false
    end
  end
end

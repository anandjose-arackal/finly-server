class CreateSystemMessageTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :system_message_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    SystemMessageType.seed_data
  end
end

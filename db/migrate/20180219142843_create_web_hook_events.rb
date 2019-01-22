class CreateWebHookEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :web_hook_events do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    WebHookEvent.seed_data
  end
end

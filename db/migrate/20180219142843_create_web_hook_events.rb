class CreateWebHookEvents < ActiveRecord::Migration
  def change
    create_table :web_hook_events do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    WebHookEvent.seed_data
  end
end

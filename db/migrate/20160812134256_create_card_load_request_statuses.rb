class CreateCardLoadRequestStatuses < ActiveRecord::Migration
  def change
    create_table :card_load_request_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

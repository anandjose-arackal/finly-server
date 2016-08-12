class CreateCardRequestStatuses < ActiveRecord::Migration
  def change
    create_table :card_request_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

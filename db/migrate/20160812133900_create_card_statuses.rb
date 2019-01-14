class CreateCardStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :card_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

class CreateCardLoadRequestActions < ActiveRecord::Migration
  def change
    create_table :card_load_request_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

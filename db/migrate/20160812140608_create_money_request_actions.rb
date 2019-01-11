class CreateMoneyRequestActions < ActiveRecord::Migration[4.2]
  def change
    create_table :money_request_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

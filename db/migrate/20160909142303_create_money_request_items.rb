class CreateMoneyRequestItems < ActiveRecord::Migration
  def change
    create_table :money_request_items do |t|
      t.references :money_request, index: true, foreign_key: true, null: false
      t.references :category, index: true, foreign_key: true, null: false
      t.references :amount, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end

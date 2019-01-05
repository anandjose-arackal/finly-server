class CreateCardBalanceHistories < ActiveRecord::Migration[4.2]
  def change
    create_table :card_balance_histories do |t|
      t.references :card, index: true, foreign_key: true
      t.references :amount, index: true, foreign_key: true
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end

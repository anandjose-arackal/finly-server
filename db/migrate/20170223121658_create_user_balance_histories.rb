class CreateUserBalanceHistories < ActiveRecord::Migration
  def change
    create_table :user_balance_histories do |t|
      t.datetime :date
      t.references :user, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.integer :card_balance_id, references: "Amounr", index: true, foreign_key: true
      t.integer :card_withdrawal_id, references: "Amount", index: true, foreign_key: true
      t.integer :card_load_id, references: "Amount", index: true, foreign_key: true
      t.integer :card_spend_id, references: "Amount", index: true, foreign_key: true
      t.integer :finly_money_balance_id, references: "Amount", index: true, foreign_key: true
      t.integer :finly_money_withdrawal_id, references: "Amount", index: true, foreign_key: true
      t.integer :finly_money_load_id, references: "Amount", index: true, foreign_key: true
      t.integer :cash_on_hand_balance_id, references: "Amount", index: true, foreign_key: true
      t.integer :cash_on_hand_withdrawal_id, references: "Amount", index: true, foreign_key: true
      t.integer :cash_on_hand_load_id, references: "Amount", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

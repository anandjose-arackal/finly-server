class CreateCashOnHands < ActiveRecord::Migration[4.2]
  def change
    create_table :cash_on_hands do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :balance_id, references: "Amount", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end

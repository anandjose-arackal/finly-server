class CreateCardLimits < ActiveRecord::Migration[4.2]
  def change
    create_table :card_limits do |t|
      t.references :card_restriction, index: true, foreign_key: true
      t.integer :amount_id, references: "Amount", index: true, foreign_key: true
      t.integer :transaction_limit
      t.integer :period_id, references: "Period", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

class CreateBalanceTallyLedgers < ActiveRecord::Migration[4.2]
  def change
    create_table :balance_tally_ledgers do |t|
      t.date :date
      t.integer :api_balance_id, references: "Amount", foreign_key: true, index: true
      t.integer :finly_database_balance_id, references: "Amount", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end

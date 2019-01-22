class CreateCompanyBalanceHistories < ActiveRecord::Migration[4.2]
  def change
    create_table :company_balance_histories do |t|
      t.references :company, index: true, foreign_key: true
      t.integer :neft_transfer_id, references: "Amount", index: true, foreign_key: true
      t.integer :company_balance_id, references: "Amount", index: true, foreign_key: true
      t.integer :company_withdrawal_id, references: "Amount", index: true, foreign_key: true
      t.integer :company_load_id, references: "Amount", index: true, foreign_key: true
      t.integer :card_load_id, references: "Amount", index: true, foreign_key: true
      t.integer :card_withdrawal_id, references: "Amount", index: true, foreign_key: true
      t.integer :card_balance_id, references: "Amount", index: true, foreign_key: true
      t.integer :card_spend_id, references: "Amount", index: true, foreign_key: true
      t.integer :finly_money_balance_id, references: "Amount", index: true, foreign_key: true
      t.integer :finly_money_withdrawal_id, references: "Amount", index: true, foreign_key: true
      t.integer :finly_money_load_id, references: "Amount", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

class CreateCardFundTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :card_fund_transactions do |t|
      t.string :transaction_id, null: false
      t.text :response, null: false
      t.string :action, null: false
      t.integer :requesting_user,:references => "user", index: true, foreign_key: true, null: false
      t.integer :for_user,:references => "user", index: true, foreign_key: true, null: false
      t.text :post_params, null: false
      t.text :post_url, null: false
      t.string :amount_value, null: false

      t.timestamps null: false
    end
  end
end

class CreateCompanyTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :company_transactions do |t|
      t.integer :company_id, :references => 'company', index: true, foreign_key: true, null: false
      t.string :request_id, null: false
      t.string :merchant_name, null: false
      t.datetime :transaction_date, null: false
      t.integer :transaction_amount_id, :references => 'amount', index: true, foreign_key: true, null: false
      t.string :transaction_type, null: false
      t.string :transaction_id, null: false
      t.integer :balance_amount_id, :references => 'amount', index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end

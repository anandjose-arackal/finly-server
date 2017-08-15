class CreateFinlyTransactions < ActiveRecord::Migration
  def change
    create_table :finly_transactions do |t|
      t.integer :finly_account_id, index: true, null: false
      t.string :finly_account_type, index: true, null: false
      t.references :transaction_type, index: true, foreign_key: true, null: false
      t.references :amount, index: true, foreign_key: true, null: false
      t.string :transaction_reference_id, null: false, index: true
      t.integer :status_id, null: false, index: true, foreign_key: true, class: 'TransactionStatus'
      t.references :payment_purpose, null: false, index: true, foreign_key: true
      t.integer :opening_balance_id, index: true, foreign_key: true, references: 'Amount'
      t.integer :closing_balance_id, index: true, foreign_key: true, references: 'Amount'
      t.integer :associated_transaction_id, index: true
      t.string :associated_transaction_type, index: true
      t.references :payment, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
    remove_column :payments, :initiating_account_opening_balance_id
    remove_column :payments, :initiating_account_closing_balance_id
    remove_column :payments, :receiving_account_opening_balance_id
    remove_column :payments, :receiving_account_closing_balance_id
    TransactionStatus.seed_data
    TransactionType.seed_data
  end
end

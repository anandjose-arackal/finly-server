class CreateTransactionDetails < ActiveRecord::Migration
  def up
    create_table :transaction_details do |t|
      t.string :transaction_reference_id
      t.string :payment_purpose
      t.string :merchant
      t.text :note
      t.string :transaction_type
      t.string :status
      t.references :amount, foreign_key: true
      t.references :finly_transaction, foreign_key: true
      t.integer :opening_balance_id, foreign_key: true, references: 'Amount'
      t.integer :closing_balance_id, foreign_key: true, references: 'Amount'
      t.references :company, index: true
      t.datetime :transaction_date
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up {
        change_column :transaction_details, :merchant, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin"
      }
    end
  end

  def down
    remove_index :transaction_details, :company_id
    drop_table :transaction_details
  end
end

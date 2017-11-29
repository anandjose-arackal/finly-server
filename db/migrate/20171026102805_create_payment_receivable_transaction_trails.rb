class CreatePaymentReceivableTransactionTrails < ActiveRecord::Migration
  def change
    create_table :payment_receivable_transaction_trails do |t|
      t.integer :transaction_id, references: "VirtualAccountTransaction", index: true, foreign_key: true
      t.boolean :find_payment_receivable
      t.boolean :creating_payment
      t.boolean :update_company_balance
      t.boolean :payment_receivable_updation

      t.timestamps null: false
    end
  end
end

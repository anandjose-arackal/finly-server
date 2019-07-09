class CreateAccountReconciliationBalances < ActiveRecord::Migration[5.2]
  def change
    create_table :account_reconciliation_balances do |t|
      t.integer :reconciliation_balance_id
      t.integer :account_id, polymorphic: true, index: true
      t.integer :account_type, polymorphic: true, index: true

      t.timestamps
    end
  end
end
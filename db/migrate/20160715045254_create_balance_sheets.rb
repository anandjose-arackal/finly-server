class CreateBalanceSheets < ActiveRecord::Migration
  def change
    create_table :balance_sheets do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :cash_in_hand_id, :references => "Amount", index: true, foreign_key: true
      t.integer :pending_reimbursement_id, :references => "Amount", index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

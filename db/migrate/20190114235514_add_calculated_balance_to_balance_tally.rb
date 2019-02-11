class AddCalculatedBalanceToBalanceTally < ActiveRecord::Migration[5.2]
  def change
    add_column :balance_tally_ledgers, :calculated_balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end

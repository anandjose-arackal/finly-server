class SplitCardSpendIntoTwoFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :user_balance_histories, :card_spend_id, :card_expenses_id
    add_column :user_balance_histories, :card_atm_withdrawal_id, :integer, references: "Amount", index: true, foreign_key: true
  end
end

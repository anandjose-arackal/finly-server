class ModifyTransactionsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :card_transactions, :billing_amount_id, :integer, foreign_key: true, index: true
  end
end

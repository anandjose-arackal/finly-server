class AddTimestampToCardTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :card_transactions, :transaction_timestamp, :datetime
  end
end

class AddTimestampToCardTransactions < ActiveRecord::Migration
  def change
    add_column :card_transactions, :transaction_timestamp, :datetime
  end
end

class AddCancelledToCardTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :card_transactions, :cancelled, :boolean, default: false
  end
end

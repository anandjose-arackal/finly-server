class AddCancelledToCardTransactions < ActiveRecord::Migration
  def change
    add_column :card_transactions, :cancelled, :boolean, default: false
  end
end

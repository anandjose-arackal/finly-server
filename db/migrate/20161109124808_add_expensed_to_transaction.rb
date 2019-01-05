class AddExpensedToTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :card_transactions, :expensed, :boolean, default: true
    add_column :card_transactions, :error_message, :text
  end
end

class AddExpensedToTransaction < ActiveRecord::Migration
  def change
    add_column :card_transactions, :expensed, :boolean, default: true
    add_column :card_transactions, :error_message, :text, default: ""
  end
end

class AddExpenseToTransaction < ActiveRecord::Migration
  def change
    add_reference :card_transactions, :expense, index: true, foreign_key: true
  end
end

class AddExpenseToTransaction < ActiveRecord::Migration[4.2]
  def change
    add_reference :card_transactions, :expense, index: true, foreign_key: true
  end
end

class RevampConnectionsBetweenCardExpenseAndTransaction < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :card_transactions, column: :expense_id
    remove_column :card_transactions, :expense_id
  end
end

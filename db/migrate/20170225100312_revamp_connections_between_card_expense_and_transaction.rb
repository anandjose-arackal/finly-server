class RevampConnectionsBetweenCardExpenseAndTransaction < ActiveRecord::Migration
  def change
    remove_foreign_key :card_transactions, column: :expense_id
    remove_column :card_transactions, :expense_id
  end
end

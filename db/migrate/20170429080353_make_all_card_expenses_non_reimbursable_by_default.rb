class MakeAllCardExpensesNonReimbursableByDefault < ActiveRecord::Migration[4.2]
  def change
    Expense.only_card_expenses.each do |expense|
      expense.update(reimbursable: false)
    end
  end
end

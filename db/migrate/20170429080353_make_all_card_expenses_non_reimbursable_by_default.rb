class MakeAllCardExpensesNonReimbursableByDefault < ActiveRecord::Migration
  def change
    Expense.only_card_expenses.each do |expense|
      expense.update(reimbursable: false)
    end
  end
end

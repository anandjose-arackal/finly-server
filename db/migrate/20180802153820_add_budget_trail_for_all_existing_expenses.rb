class AddBudgetTrailForAllExistingExpenses < ActiveRecord::Migration[4.2]
  def change
    Expense.where(expense_status_id: ExpenseStatus.ids_for([:submitted, :verified])).each do |expense|
      # saving all the expenses to the budget trail
      BudgetsCalculator::Calculate::ExpenseBudgetsProcessor.new.save_trail(expense)
    end
    Payment.where(payment_status_id: [PaymentStatus.id_for(:scheduled), PaymentStatus.id_for(:processing), PaymentStatus.id_for(:possible_failure), PaymentStatus.id_for(:completed)]).each do |payment|
      # saving all the payments to the budget trail
      BudgetsCalculator::Calculate::PaymentBudgetsProcessor.new.save_trail(payment)
    end
  end
end
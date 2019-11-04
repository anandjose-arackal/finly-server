class BudgetManager::BudgetsCalculator::Calculate::Category < BudgetManager::BudgetsCalculator::Calculate::Base
  attr_accessor :category_id

  def init
    super
    self.category_id = budget.budgetable_id
  end

  def process
    if items_requested
      expenses = Expense.user_budget_expenses(budget.start_date, budget.end_date).with_category(self.category_id).with_amount
      self.spent_amount += expenses.sum(:value)
      self.budget_trail_items += expenses

      payments = Payment.budget_payments(budget.start_date, budget.end_date).with_category(self.category_id).with_amount
      self.spent_amount += payments.sum(:value)
      self.budget_trail_items += payments
    else
      self.spent_amount += Expense.user_budget_expenses(budget.start_date, budget.end_date).with_category(self.category_id).with_amount.sum(:value)
      self.spent_amount += Payment.budget_payments(budget.start_date, budget.end_date).with_category(self.category_id).with_amount.sum(:value)
    end
  end
end
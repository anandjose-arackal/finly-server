class Budgets::Calculate::Category < Budgets::Calculate::Base
  attr_accessor :category_id

  def init
    self.budget = params[:budget]
    self.spent_amount = 0
    self.category_id = budget.budgetable_id
  end

  def process
    self.spent_amount = Expense.user_budget_expenses(budget.start_date, budget.end_date).with_category(self.category_id).with_amount.sum(:value)
  end
end
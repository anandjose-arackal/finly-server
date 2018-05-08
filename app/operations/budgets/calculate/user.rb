class Budgets::Calculate::User < Budgets::Calculate::Base
  attr_accessor :budget_user

  def init
    self.budget = params[:budget]
    self.spent_amount = 0
    self.budget_user = User.find_by id: budget.budgetable_id
  end

  def process
    self.spent_amount = self.budget_user.expenses.user_budget_expenses(budget.start_date, budget.end_date).with_amount.sum(:value)
  end

end
class BudgetsProcessor::Calculate::User < BudgetsProcessor::Calculate::Base
  attr_accessor :budget_user

  def init
    super
    self.budget_user = User.find_by id: budget.budgetable_id
  end

  def process
    #todo add payment by the user??

    if items_requested
      expenses = self.budget_user.expenses.user_budget_expenses(budget.start_date, budget.end_date).with_amount
      self.spent_amount += expenses.sum(:value)
      self.budget_trail_items += expenses
    else
      self.spent_amount = self.budget_user.expenses.user_budget_expenses(budget.start_date, budget.end_date).with_amount.sum(:value)
    end
  end

end
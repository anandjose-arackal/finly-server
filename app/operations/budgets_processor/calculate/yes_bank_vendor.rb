class BudgetsProcessor::Calculate::YesBankVendor < BudgetsProcessor::Calculate::Base
  attr_accessor :yes_bank_vendor

  def init
    self.budget = params[:budget]
    self.spent_amount = 0
    self.yes_bank_vendor = YesBankVendor.find_by id: budget.budgetable_id
  end

  def process
    self.spent_amount = self.user.expenses.user_budget_expenses(budget.start_date, budget.end_date).with_amount.sum(:value)

  end

end
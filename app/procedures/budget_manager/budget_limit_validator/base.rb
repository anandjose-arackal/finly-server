class BudgetManager::BudgetLimitValidator::Base < Transactions::API
  attr_accessor :budgets, :budget_contributions, :previous_budget_contributions,
  :ignore_unbudgetables

  step :initialize!

  step :process!
end

# Script to recalculate budgets for Supr daily

class RecalculateSuprDailyBudgets
  def self.run
    Company.find(184).budgets.each do |budget|
      BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: true, calculate_trail_items: false})
    end; nil
  end
end

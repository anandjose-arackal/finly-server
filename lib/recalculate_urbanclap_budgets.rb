# Script to recalculate budgets for Urbanclap

class RecalculateUrbanclapBudgets
  def self.run
    Company.find(220).budgets.each do |budget|
      BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: true, calculate_trail_items: false})
    end; nil
  end
end

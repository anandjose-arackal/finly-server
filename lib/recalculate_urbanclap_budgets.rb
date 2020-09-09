# Script to recalculate budgets for Urbanclap

class RecalculateUrbanclapBudgets
  def self.run
    Budget.where(company_id: 220).find_in_batches do |budgets|
      budgets.each do |budget|
        BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: true, calculate_trail_items: false})
      end
    end
  end
end

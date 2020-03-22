class BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  attr_accessor :budget, :entity, :trail_hash, :applicable_trails

  def initialize(budget = nil)
    self.budget = budget
  end

  def save_trail

    if self.trail_hash[:id].present?
      budget_trail = BudgetTrail.find_by(id: self.trail_hash[:id])
      budget_trail.update(self.trail_hash)
    else
      budget_trail = BudgetTrail.new(self.trail_hash)
      budget_trail.save
    end
  end

  def destroy_trail

  end

  protected

  def pending_spent_amount

  end

end
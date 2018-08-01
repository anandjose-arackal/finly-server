class BudgetsCalculator::Calculate::BudgetsProcessor

  attr_accessor :budget, :entity

  def initialize(budget)
    self.budget = budget
  end

  def spent_amount

  end

  # i.e. these are the entities that have consumed this particular budget
  def spent_entities

  end

  def save_trail

  end

  protected

end
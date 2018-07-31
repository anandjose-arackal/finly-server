class BudgetsProcessor::BaseAdapter

  attr_accessor :budget, :entity

  def initialize(budget)
    self.budget = budget
  end

  def categories_total(budget, start_date, end_date)

  end

  def categories_entity_list

  end

  def cost_centers_total(budget)

  end

  def cost_centers_entity_list

  end

  def departments_total

  end

  def departments_entity_list

  end

  def locations_total

  end

  def locations_entity_list

  end

  def vendors_total

  end

  def vendors_entity_list

  end

  # todo - custom fields total

  protected

  # generalized method to extract details from the BudgetTrail model
  def budget_trail_entries(entity_type, start_date, end_date)
    BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(entity_type: entity_type)
  end

end
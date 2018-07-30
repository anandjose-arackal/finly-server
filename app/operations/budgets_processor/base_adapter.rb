class BudgetsProcessor::BaseAdapter

  attr_accessor :budget, :entity

  def budget_amount

  end

  def spent_amount(budget, entity)

  end

  def spent_between(budget, entity, start_date, end_date)

  end
end
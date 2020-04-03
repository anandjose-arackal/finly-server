class ExportManager::Master::Budgets::UsageSummary < ExportManager::Builders::Spreadsheet

  attr_accessor :budgets, :index

  description 'Budget Usage Summary'
  configurable true
  system :fi
  screen ['budget_group_criteria.index']
  handle :budget_summary

  validate :input

  attribute :serial_no
  attribute :budget_name
  attribute :budget_criteria_name
  attribute :budget_start_date
  attribute :budget_end_date
  attribute :budget_amount
  attribute :budget_usage
  attribute :usage_percentage

  def input
    budget_group_id = params[:budget_group_id]
    op = BudgetManager::BudgetGroupCriteria::Ops::Index.(params: {id: budget_group_id}, "current_user" => User.first)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    budget_group_criteria = op["budget_group_criteria"]
    self.budgets = Budget.with_budget_criteria_id(budget_group_criteria.pluck(:id))
    self.index = 0
    return self.budgets
  end

  def serial_no(budget)
    self.index += 1
    return self.index
  end

  def budget_name(budget)
    budget.name
  end

  def budget_criteria_name(budget)
    budget.budget_group_criterium.name
  end

  def budget_start_date(budget)
    budget.start_date.strftime("%d %B, %Y")
  end

  def budget_end_date(budget)
    budget.end_date.strftime("%d %B, %Y")
  end

  def budget_amount(budget)
    budget.budget_consumption.budget_amount&.value.to_f
  end

  def budget_usage(budget)
    budget.budget_consumption.spent_amount&.value.to_f
  end

  def usage_percentage(budget)
    spent_amount = budget.budget_consumption.spent_amount&.value.to_f
    return 0 if budget.budget_consumption.budget_amount.value == 0
    return ((spent_amount / budget.budget_consumption.budget_amount&.value.to_f) * 100).round(2)
  end

end
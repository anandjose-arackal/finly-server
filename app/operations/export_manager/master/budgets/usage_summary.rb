class ExportManager::Master::Budgets::UsageSummary < ExportManager::Master::BaseMaster

  attr_accessor :spent_amount

  register_handle :budget_summary
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input

  register_fields [
                  budget_name: {spreadsheet: true, pdf: false},
                  budget_start_date: {spreadsheet: true, pdf: false},
                  budget_end_date: {spreadsheet: true, pdf: false},
                  budget_amount: {spreadsheet: true, pdf: false},
                  budget_usage: {spreadsheet: true, pdf: false},
                  usage_percentage: {spreadsheet: true, pdf: true}
                  ]

  def input
    op = ::Budgets::Index.(user, params)
    unless op.success?
      add_message :error, result.messages[:error]
      return
    end
    budgets = op.budgets
    all_budget_ids = []
    # extracting all the budget ids including the children
    budgets.each do |budget|
      all_budget_ids += budget.children.pluck(:id)
      all_budget_ids << budget.id
    end
    Budget.with_id(all_budget_ids)
  end

  def budget_name(budget)
    budget.name
  end

  def budget_start_date(budget)
    budget.start_date
  end

  def budget_end_date(budget)
    budget.end_date
  end

  def budget_amount(budget)
    budget.budget_amount&.value
  end

  def budget_usage(budget)
    # if self.spent_amount.present?
    #   return self.spent_amount
    # else
    #   processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
    #   self.spent_amount = processor_instance.spent_amount
    #   return self.spent_amount
    # end
    processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
    spent_amount = processor_instance.spent_amount
  end

  def usage_percentage(budget)
    processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
    spent_amount = processor_instance.spent_amount
    return ((spent_amount / budget.budget_amount&.value.to_f) * 100).round(2)
  end

end
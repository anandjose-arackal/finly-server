class ExportManager::Master::Budgets::UsageEntities < ExportManager::Master::BaseMaster

  register_handle :budget_entities
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input
  register_fields [
                      entity_name: {spreadsheet: true, pdf: false},
                      entity_type: {spreadsheet: true, pdf: false},
                      category: {spreadsheet: true, pdf: false},
                      department: {spreadsheet: true, pdf: false},
                      cost_center: {spreadsheet: true, pdf: false},
                      location: {spreadsheet: true, pdf: false},
                      amount: {spreadsheet: true, pdf: false},

                  ]

  def input
    op = Budgets::Show.(user, params)
    unless op.success?
      add_message :error, result.messages[:error]
      return
    end
    budget = op.budget
    processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)

  end
end
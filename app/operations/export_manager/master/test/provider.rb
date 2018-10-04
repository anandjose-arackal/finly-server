class ExportManager::Master::Test::Provider < ExportManager::Master::BaseMaster

  register_handle :test
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input
  register_fields [
                      {id: {spreadsheet: true, pdf: true}},
                      :merchant
                  ]

  def input
    Expense.limit(10)
  end

  def id(entry)
    entry.id
  end

  def merchant(entry)
    entry.merchant_name
  end

end
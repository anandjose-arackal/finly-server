class ExportManager::Master::TallyVouchers::Expenses < ExportManager::Master::BaseMaster

  register_handle :tally_expense_voucher_xls
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input
  # Voucher type	Report name	Invoice date	Reference number	Employee Name	Expense Merchant	Expense Date	Expense Category Name	GL code	Expense Currency	Expense Amount	Department	Purpose
  register_fields [
                      report_name: {spreadsheet: true},
                      reference_number: {spreadsheet: true},
                      employee_name: {spreadsheet: true},
                      merchant: {spreadsheet: true},
                      date: {spreadsheet: true},
                      category: {spreadsheet: true},
                      gl_code: {spreadsheet: true},
                      currency: {spreadsheet: true},
                      amount: {spreadsheet: true},
                      purpose: {spreadsheet: true}
                  ]

  def input
    result = ::Reports::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    Expense.with_report_id(result.reports.pluck(:id)).include_details
  end


  def report_name(expense)
    expense.report.name
  end

  def reference_number(expense)
    expense.report.id
  end

  def employee_name(expense)
    expense.user.name
  end

  def merchant(expense)
    expense.merchant_name
  end

  def date(expense)
    expense.date.strftime("%d.%m.%Y")
  end

  def category(expense)
    expense.category.name
  end

  # Jugaad for stanza to handle their direct and indirect employee GL Codes
  STANZA_INDIRECT_GL_MAPPING = {
      '321006': '321006',
      '321002': '321002',
      '321001': '321001',
      '306003': '306003',
      '321004': '321004',
      '321003': '321003',
      '333006': '333006',
      '306005': '306005',
      '305001': '305001',
      '321005': '321005'
  }

  def gl_code(expense)
    gl = expense.category.gl_code
    return gl unless STANZA_INDIRECT_GL_MAPPING.keys.include?(gl)
    return gl unless expense.report.policy.name.downcase.include?('indirect')
    STANZA_INDIRECT_GL_MAPPING[gl]
  end

  def currency(expense)
    expense.amount.currency.country_code
  end

  def amount(expense)
    expense.amount.value
  end

  def purpose(expense)
    expense.note
  end

end
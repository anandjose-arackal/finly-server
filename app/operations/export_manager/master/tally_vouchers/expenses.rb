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

    reports = result.reports

    if params[:filtered]
      reports = reports.processed
    else
      id = params[:id] || params[:report_id]
      id = id.split(',')
      reports = reports.with_id(id)
    end
    report_ids = reports.pluck(:id)

    Expense.with_report_id(report_ids).include_details
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
      "210004": 321006,
      "202005": 321002,
      "221001": 321001,
      "217002": 306003,
      "211002": 321004,
      "321005": 321003,
      "211004": 333006,
      "217003": 306005,
      "216001": 305001,
      "210003": 321005
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
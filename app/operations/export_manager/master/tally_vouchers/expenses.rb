class ExportManager::Master::TallyVouchers::Expenses < ExportManager::Master::BaseSubscriber

  bus ExportManager::Master::BaseMaster
  subscribe :tally_expense_voucher_xls
  generators ExportManager::Generator::Spreadsheet
  processor ExportManager::Processor::Synchronous
  validate :input
  fields [
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
      '217002': '306003',
      '202001': '327003',
      '202002': '327004',
      '202004': '327002',
      '204001': nil,
      '204003': nil,
      '204005': nil,
      '204002': nil,
      '204004': nil,
      '204006': nil,
      '205003': nil,
      '206001': '329001',
      '206002': '332001',
      '206003': '332003',
      '206004': nil,
      '206005': nil,
      '216001': '305001',
      '210002': '336001',
      '306006': '306006',
      '211001': nil,
      '211004': '333006',
      '211002': '333003',
      '321001': '321001',
      '321002': '321002',
      '321003': '321003',
      '321004': '321004',
      '210003': '321005',
      '210004': '321006'
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
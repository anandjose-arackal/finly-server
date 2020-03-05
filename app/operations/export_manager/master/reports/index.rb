class ExportManager::Master::Reports::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Report Export'
  configurable true
  system :vp
  screen 'report.index'
  handle :reports
  validate :input

  attribute :report_id
  attribute :report_name
  attribute :report_status_name
  attribute :report_creator
  attribute :created_at
  attribute :report_creator_employee_id
  attribute :report_creator_payroll_id

  def input
    result = ::Reports::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    reports = result.reports
    Expense.where(report_id: reports.pluck(:id)).include_details
  end

  def report_id(expense)
    expense.report.id
  end

  def report_name(expense)
    expense.report.name
  end

  def report_status_name(expense)
    expense.report.status.name
  end

  def report_creator(expense)
    expense.report.user.name
  end

  def report_creator_employee_id(expense)
    expense.report.user.employee_id
  end

  def report_creator_payroll_id(expense)
    expense.report.user.payroll_id
  end

  def created_at(expense)
    expense.report.created_at&.strftime('%d-%b-%Y')
  end


end
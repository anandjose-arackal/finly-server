class ExportManager::Master::Reports::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Report Export'
  configurable true
  system :em
  screen 'reports.index'
  handle :reports
  validate :input

  attribute :finly_ref_no
  attribute :report_name
  attribute :report_status_name
  attribute :report_creator
  attribute :report_created_at
  attribute :report_creator_employee_id
  attribute :report_creator_payroll_id
  attribute :expense_id
  attribute :merchant_name
  attribute :expense_category
  attribute :expense_category_gl_code
  attribute :expense_currency_code
  attribute :expense_amount
  attribute :expense_date
  attribute :expense_note
  attribute :expense_status
  attribute :expense_user
  attribute :expense_user_email
  attribute :expense_user_mobile_number
  attribute :expense_user_department
  attribute :expense_user_location
  attribute :expense_user_cost_center
  attribute :distance_expense_locations, default: false
  attribute :distance_in_km, default: false
  attribute :maps_distance_in_km, default: false
  attribute :expense_type
  attribute :expense_checkin_date
  attribute :expense_checkout_date
  attribute :expense_reimbursable
  attribute :expense_spent_from_account
  attribute :report_policy
  attribute :report_submission_date
  attribute :report_creation_date
  attribute :receipt_link
  attribute :expense_igst
  attribute :expense_sgst_cgst
  attribute :bank_reference_number
  attribute :source_account
  attribute :settlement_date
  attribute :finance_approved_date
  attribute :reporting_currency
  attribute :reporting_amount
  attribute :conversion_rate

  section :expense_custom_fields do
    attribute :expense_custom_fields, dynamic: true
  end

  section :report_custom_fields do
    attribute :report_custom_fields, dynamic: true
  end

  section :report_approvers do
    attribute :reviewal_chain, dynamic: true
  end

  def expense_custom_fields(row, expense)
    expense.custom_fields.includes(:field_configuration).each do |custom_field|
      row.add(custom_field.field_configuration&.field_name, custom_field.string_value)
    end
  end

  def report_custom_fields(row, expense)
    expense.report.custom_fields.includes(:field_configuration).each do |custom_field|
      row.add(custom_field.field_configuration&.field_name, custom_field.string_value)
    end
  end

  def reviewal_chain(row, expense)
    expense.report&.dlrms.group_by(&:level_number).map do |level_number, group|
      reviewer_name = group.map(&:reviewer).compact.map(&:name).join(", ")
      dlrm = group.find {|d| d if d.action_taken_by_id.present?}
      action_taker = dlrm&.action_taken_by&.name
      action = dlrm&.action&.name&.humanize 
      action_date = dlrm&.action_taken_at&.strftime("%d-%m-%Y, %H:%M")
      row.add("Action Name for Level #{level_number}", action)
      row.add("Action Taken By for Level #{level_number}", action_taker)
      row.add("Action Date for Level #{level_number} (dd/mm/yyyy)", action_date)
      row.add("Reviewer(s) for Level #{level_number}", reviewer_name)
    end
  end

  def input
    id = (params[:report_id] or params[:report_ids] or params[:with_id]).split(',').compact rescue nil
    params[:filter_ids] = id if id.present?
    result = ::Reports::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    reports = result.reports
    Expense.where(report_id: reports.pluck(:id)).include_details
  end

  def finly_ref_no(expense)
    expense.report.id
  end

  def report_name(expense)
    expense.report&.name
  end

  def report_status_name(expense)
    status_name(expense.report)
    # expense.report.status&.name
  end

  def report_creator(expense)
    expense.report.user&.name
  end

  def report_creator_employee_id(expense)
    expense.report.user&.employee_id
  end

  def report_creator_payroll_id(expense)
    expense.report.user&.payroll_id
  end

  def report_created_at(expense)
    expense.report.created_at&.strftime('%d-%b-%Y')
  end

  def merchant_name(expense)
    expense.merchant_name
  end

  def expense_id(expense)
    expense.id
  end

  def expense_category(expense)
    expense.category&.full_name
  end

  def expense_category_gl_code(expense)
    expense.category&.gl_code
  end

  def expense_currency_code(expense)
    expense.amount&.currency&.country_code
  end

  def expense_amount(expense)
    expense.amount&.value
  end

  def expense_date(expense)
    expense.date&.strftime('%d-%b-%Y')
  end

  def expense_note(expense)
    expense.note
  end

  def expense_status(expense)
    expense.expense_status&.name&.humanize
  end

  def expense_user(expense)
    expense.user.first_name
  end

  def expense_user_email(expense)
    expense.user.email
  end

  def expense_user_mobile_number(expense)
    expense.user.mobile_number
  end

  def expense_user_department(expense)
    expense.user.department&.name
  end

  def expense_user_location(expense)
    expense.user.location&.name
  end

  def expense_user_cost_center(expense)
    expense.user.cost_center&.name
  end

  def distance_expense_locations(expense)
    expense.distance_expense&.locations&.pluck(:name).join(', ') if expense.distance_expense?
  end

  def distance_in_km(expense)
    expense.distance_expense.distance_value if expense.distance_expense?
  end

  def maps_distance_in_km(expense)
    expense.distance_expense.maps_distance_value if expense.distance_expense?
  end

  def expense_type(expense)
    expense.expense_type&.exportable_name
  end

  def expense_reimbursable(expense)
    expense.reimbursable ? 'YES' : 'NO'
  end

  def expense_spent_from_account(expense)
    expense.spent_from.present? ? expense.spent_from&.name : "NONE"
  end

  def report_policy(expense)
    expense&.report&.policy&.name
  end

  def report_submission_date(expense)
    expense&.report&.submitted_at&.strftime("%d-%m-%Y, %H:%M")
  end

  def report_creation_date(expense)
    expense&.report&.created_at&.strftime("%d-%m-%Y, %H:%M")
  end

  def receipt_link(expense)
    expense&.receipts&.first&.image&.url
  end

  def expense_igst(expense)
    gst_applicable = expense.category&.gst_applicable?
    (gst_applicable ? (expense.gst_type&.name == 'igst' ? (expense.gst_amount&.value.to_f)&.round(2) : '') : '')
  end

  def expense_sgst_cgst(expense)
    gst_applicable = expense.category&.gst_applicable?
    ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value.to_f) / 2)&.round(2) : '') : '') rescue '')
  end

  def bank_reference_number(expense)
    # expense.report&.bank_reference_number
    expense.report&.utr
  end

  def source_account(expense)
    expense.report&.source_account
  end

  def settlement_date(expense)
    expense.report&.report_processor_group_mapping&.completed_at&.strftime("%d-%m-%Y, %H:%M")
  end

  def finance_approved_date(expense)
    expense.report&.approved_at&.strftime("%d-%b-%Y")
  end

  def status_name(report)
    return nil if report.blank?
    if report.processing? and report.controlling_user?(user)
      'Awaiting Approval'
    elsif report.auto_approved?
      'Auto Approved'
    else
      report.status_name
    end
  end

  def reporting_currency(expense)
    expense&.report.policy.base_currency.country_code
  end

  def reporting_amount(expense)
    expense&.report.total_amount
  end

  def conversion_rate(expense)
    sym = expense&.report&.base_currency&.country_code
    if sym.present?
      if expense&.amount.present? && expense&.amount[sym].present?
        if expense&.amount[sym] != 0
          return (expense&.amount.value / expense&.amount[sym] rescue 0)
        else
          #retrun zero incase of divide by zero
          0
        end
      end
    end
    end

  def expense_checkin_date(expense)
    expense.usage_date_start&.strftime('%d-%b-%Y')
  end

  def expense_checkout_date(expense)
    expense.usage_date_end&.strftime('%d-%b-%Y')
  end

end
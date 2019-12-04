class AccountingExports::Master::Expenses::Export < AccountingExports::Master::Processor::Export

  bus AccountingExports::Master::BaseMaster
  subscribe 'expenses.export'
  has_scope :filter_date, using: [:from, :to], type: :hash

  attr_accessor :expenses, :reports

  def process
    objects = get_records(params)
    self.records = set_record_format(objects)
  end

  def get_records(data)
    self.reports = Report.admin_associated_items(current_user).not_open
    self.reports = apply_scopes(self.reports, params)
    reports.approved.includes({user:[ :profile,:location, :department]},expenses:[:category,:amount, :gstin_location,:state_of_expense, :expense_tax_type],policy:[policy_user_roles: :user])

  end
  
  def set_record_format(expenses)
    self.records =[]
    reports.each do |report|
      fm = report.policy.policy_user_roles.where(user_role_id: 2).first&.user
      report.expenses.each do |expense|
      row={
      expense_id: expense.id,
      expense_amount: expense.amount&.value,
      expense_amount_country_code:expense.amount&.currency&.country_code,
      note:expense.note,
      date: expense.date&.strftime("%d-%b-%Y"),
      merchant_name:expense.merchant_name,
      user_name: expense.user&.name,
      email: expense.user&.email,
      employee_id: expense.user&.profile&.employee_id,
      employee_name: expense.user&.department&.name,
      department_code: expense.user&.department&.department_code,
      cost_center: expense.user&.cost_center&.name,
      cost_center_code: expense.user&.cost_center&.cost_center_code,
      opertion_unit: (expense.user.gl_config[:operation_unit] rescue ''),
      expense_type: expense.expense_type.name,
      created_at: expense.created_at&.strftime("%d-%b-%Y"),
      updated_at: expense.updated_at&.strftime("%d-%b-%Y"),
      report_id: expense.report&.id,
      category_name:expense.category&.name,
      category_gl_code: expense.category&.gl_code,
      spent_from: expense.spent_from&.name,
      gst_appliable: gst_applicable  = expense.category&.gst_applicable?,
      tax_type: (gst_applicable ? expense.expense_tax_type&.name&.humanize : ''),
      tax_percentage: (gst_applicable ? expense.gst_percentage : ''),
      gst_type: (gst_applicable ? expense.gst_type&.name&.humanize&.upcase : ''),
      gst_amount: (gst_applicable ? expense.gst_amount&.value&.round(2) : ''),
      igst:(gst_applicable ? (expense.gst_type&.name == 'igst' ? expense.gst_amount&.value : '') : ''),
      cgst: ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value)/2).round(2) : '') : '') rescue ''),
      sgst: ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value)/2).round(2) : '') : '') rescue ''),
      net_total: (gst_applicable ? ((expense.amount&.value || 0) - (expense.gst_amount&.value&.round(2) || 0))&.round(2) : expense.amount&.value),
      gst_location: (gst_applicable ? expense.gstin_location&.location : ''),
      gst_state:(gst_applicable ? expense.gstin_location&.state&.name : ''),
      gst_state_of_expense:(gst_applicable ? expense.state_of_expense&.name : ''),
      hsn_sac:(gst_applicable ? expense.hsn_sac : ''),
      merchant_bill_no:(gst_applicable ? expense.merchant_bill_no : ''),
      tax_rate:(gst_applicable ? expense.tax_rate&.rate&.to_f : ''),
      gstin:(gst_applicable ? expense.gstin_location&.gstin : ''),
      finance_manager: "#{fm&.first_name} #{fm&.last_name}"
      }
      records <<  row
      end
    end
    records
  end
  
  end
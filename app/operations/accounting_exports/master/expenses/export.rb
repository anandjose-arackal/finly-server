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
    reports.approved.includes({user: [:profile, :location, :department]}, expenses: [:category, :amount, :gstin_location, :state_of_expense, :expense_tax_type, :manual_expense, :card_expense], policy: [policy_user_roles: :user])

  end

  def set_record_format(expenses)
    self.records = []
    reports.each do |report|
      fm = report.policy.policy_user_roles.where(user_role_id: 2).first&.user
      report.expenses.each do |expense|
        row = {
            expense_id: expense.id,
            amount_value: expense.amount&.value,
            amount_currency: expense.amount&.currency&.country_code,
            purpose: expense.note,
            bill_date: expense.date&.strftime("%d-%b-%Y"),
            merchant_name: expense.merchant_name,
            user_name: expense.user&.name,
            user_email: expense.user&.email,
            user_employee_id: expense.user&.profile&.employee_id,
            user_department_name: expense.user&.department&.name,
            user_department_code: expense.user&.department&.department_code,
            cost_center: expense.user&.cost_center&.name,
            cost_center_code: expense.user&.cost_center&.cost_center_code,
            operating_unit: (expense.user.gl_config[:operation_unit] rescue ''),
            expense_type: expense.expense_type.name,
            created_at: expense.created_at&.strftime("%Y:%m:%d %H:%M:%S"),
            updated_at: expense.updated_at&.strftime("%Y:%m:%d %H:%M:%S"),
            report_id: expense.report&.id,
            category_name: expense.category&.name,
            category_gl_code: expense.category&.gl_code,
            spent_from: expense.spent_from&.name,
            gst_appliable: gst_applicable = expense.category&.gst_applicable?,
            expense_tax_type: (gst_applicable ? expense.expense_tax_type&.name&.humanize : ''),
            gst_percentage: (gst_applicable ? expense.gst_percentage : ''),
            gst_type: (gst_applicable ? expense.gst_type&.name&.humanize&.upcase : ''),
            gst_amount: (gst_applicable ? expense.gst_amount&.value&.round(2) : ''),
            igst_amount: (gst_applicable ? (expense.gst_type&.name == 'igst' ? expense.gst_amount&.value : '') : ''),
            cgst_amount: ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value) / 2).round(2) : '') : '') rescue ''),
            sgst_amount: ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value) / 2).round(2) : '') : '') rescue ''),
            net_total_amount: (gst_applicable ? ((expense.amount&.value || 0) - (expense.gst_amount&.value&.round(2) || 0))&.round(2) : expense.amount&.value),
            gst_location: (gst_applicable ? expense.gstin_location&.location : ''),
            merchant_state: (gst_applicable ? expense.gstin_location&.state&.name : ''),
            state_of_expense: (gst_applicable ? expense.state_of_expense&.name : ''),
            hsn_sac: (gst_applicable ? expense.hsn_sac : ''),
            merchant_bill_no: (gst_applicable ? expense.merchant_bill_no : ''),
            tax_rate: (gst_applicable ? expense.tax_rate&.rate&.to_f : ''),
            gstin: (gst_applicable ? expense.gstin_location&.gstin : ''),
            finance_manager: "#{fm&.first_name} #{fm&.last_name}"
        }
        records << row
      end
    end
    records
  end

end
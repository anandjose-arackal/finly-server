class AccountingExports::Master::Expense::Export < AccountingExports::Master::Processor::Export

  bus AccountingExports::Master::BaseMaster
  subscribe 'expense.export'

  attr_accessor :expenses
  
  def get_record(data)
    user_ids = current_company.users.pluck(:id)
    expenses = Expense.where(user_id: expenses)
  end
  
  def set_record_format
    expenses.each do |expense|
      row={
      expense_id: expense.id,
      expense_amount: expense.amount.value,
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
      net_total: (gst_applicable ? (expense.amount&.value - (expense.gst_amount&.value&.round(2) || 0))&.round(2) : expense.amount&.value),
      gst_location: (gst_applicable ? expense.gstin_location&.location : ''),
      gst_state:(gst_applicable ? expense.gstin_location&.state&.name : ''),
      gst_state_of_expense:(gst_applicable ? expense.state_of_expense&.name : ''),
      hsn_sac:(gst_applicable ? expense.hsn_sac : ''),
      merchant_bill_no:(gst_applicable ? expense.merchant_bill_no : ''),
      tax_rate:(gst_applicable ? expense.tax_rate&.rate&.to_f : ''),
      gstin:(gst_applicable ? expense.gstin_location&.gstin : ''),
      }
      records <<  row
    end
  end
  
  end
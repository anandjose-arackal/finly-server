class Personalizer::Adapters::Company190::ExportTemplates190::ExpenseExportTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports, :role_id

  has_scope :filter_date, using: [:from, :to], type: :hash

  def pre_validate

  end

  def init

    if params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
      params[:role_id] = self.role_id
    end

    if self.role_id.blank?
      add_message :error, 'You are not authorized to do this'
    end

    case self.role_id
      when UserRole.id_for(:admin), UserRole.id_for(:auditor)
      if self.user.company_admin? || self.user.auditor?
        self.reports = Report.admin_associated_items(user).not_open
      elsif user.policy_admin?
        # todo Take care of policy admins
        self.reports = Report.admin_associated_items(user).not_open
      end
      when UserRole.id_for(:manager)
      self.reports = Report.reviewer_associated_items(user).not_open
      when UserRole.id_for(:finance_manager)
      self.reports = Report.finance_associated_items(user).not_open
    end

    self.reports = reports.approved.includes({user: :profile},expenses:[:category,:amount, :gstin_location,:state_of_expense, :expense_tax_type],policy:[policy_user_roles: :user])
    self.reports = apply_scopes(self.reports, params)

    self.headers = ["Expense ID",
                    "Amount value",
                    "Amount currency",
                    "Purpose",
                    "Date",
                    "Merchant name",
                    "User name",
                    "User email",
                    "User employee code",
                    "User department",
                    "User department code",
                    "Cost center",
                    "Cost center code",
                    "Operatiing unit",
                    "Expense type",
                    "Created at",
                    "Updated at",
                    "Report ID",
                    "Category name",
                    "Category gl name",
                    "Spend pocket",
                    "Expense tax type",
                    "Gst percentage",
                    "Gst type",
                    "Gst amount",
                    "Igst amount",
                    "Cgst amount",
                    "Sgst amount",
                    "Net total amount",
                    "Gst Details",
                    "Gstin Location",
                    "Merchant state",
                    "State of expense",
                    "Hsn sac",
                    "Merchant bill no",
                    "Tax rate",
                    "GSTIN",
                    "Finance Manager"]

    self.contents = []
    reports.each do |report|
      fm = report.policy.policy_user_roles.where(user_role_id: 2).first&.user
      report.expenses.each do |expense|
        data_arr = []
        data_arr << expense.id
        data_arr << expense.amount.value
        data_arr << expense.amount&.currency&.country_code
        data_arr << expense.note
        data_arr << expense.date&.strftime("%d-%b-%Y")
        data_arr << expense.merchant_name
        data_arr << expense.user&.name
        data_arr << expense.user&.email
        data_arr << expense.user&.profile&.employee_id
        data_arr << expense.user&.department&.name
        data_arr << expense.user&.department&.department_code
        data_arr << expense.user&.cost_center&.name
        data_arr << expense.user&.cost_center&.cost_center_code
        data_arr << (expense.user.gl_config[:operation_unit] rescue '')
        data_arr << expense.expense_type.name
        data_arr << expense.created_at&.strftime("%d-%b-%Y")
        data_arr << expense.updated_at&.strftime("%d-%b-%Y")
        data_arr << expense.report&.id
        data_arr << expense.category&.name
        data_arr << expense.category&.gl_code
        data_arr << expense.spent_from&.name
        gst_applicable  = expense.category&.gst_applicable?
        data_arr << (gst_applicable ? expense.expense_tax_type&.name&.humanize : '')
        data_arr << (gst_applicable ? expense.gst_percentage : '')
        data_arr << (gst_applicable ? expense.gst_type&.name&.humanize&.upcase : '')
        data_arr << (gst_applicable ? expense.gst_amount&.value&.round(2) : '')
        data_arr << (gst_applicable ? (expense.gst_type&.name == 'igst' ? expense.gst_amount&.value : '') : '')
        data_arr << ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value)/2).round(2) : '') : '') rescue '')
        data_arr << ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value)/2).round(2) : '') : '') rescue '')
        data_arr << (gst_applicable ? (expense.amount&.value - (expense.gst_amount&.value&.round(2) || 0))&.round(2) : expense.amount&.value)
        data_arr << ''
        data_arr << (gst_applicable ? expense.gstin_location&.location : '')
        data_arr << (gst_applicable ? expense.gstin_location&.state&.name : '')
        data_arr << (gst_applicable ? expense.state_of_expense&.name : '')
        data_arr << (gst_applicable ? expense.hsn_sac : '')
        data_arr << (gst_applicable ? expense.merchant_bill_no : '')
        data_arr << (gst_applicable ? expense.tax_rate&.rate&.to_f : '')
        data_arr << (gst_applicable ? expense.gstin_location&.gstin : '')
        data_arr << "#{fm.first_name} #{fm.last_name}" if fm.present?
        self.contents << data_arr
      end
    end
  end

end
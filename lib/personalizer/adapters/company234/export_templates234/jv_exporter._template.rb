class Personalizer::Adapters::Company234::ExportTemplates234::JVExporter < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports, :role_id

  has_scope :filter_approved_date, using: [:from, :to], type: :hash

  def init
    if params.dig(:filter_date, :from).present?
      params.merge!({filter_approved_date: {from: params.dig(:filter_date, :from), to: params.dig(:filter_date, :to)}})
    end

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

    self.reports = reports.processed.includes({user: :profile}, expenses: [:category, :amount])
    self.reports = apply_scopes(self.reports, params)
    self.headers = [
        'POSTINGDATE',
        'DOCTYPE',
        'DOCNO',
        'ACCTYPE',
        'ACCNO',
        'ACCNAME',
        'AMOUNT Debit',
        'AMOUNT Credit',
        'BRANCH DIMENSION',
        'BRANCH DIMENSION VALUE',
        'DEPART DIMENSION',
        'DEPART DIMENSION VALUE',
        'EMPLOYEE DIMENSION',
        'EMPLOYEE DIMENSION VALUE',
        'VOUCHER NARRATION',
        'LINE NARRATION',
        'NEXT LINE IDENTIFIER'
    ]
    self.contents = []
    sl_no = 1
    reports.each do |report|
      total_amount = 0
      report.expenses.each do |expense|
        total_amount += expense&.amount&.value
        user = report.user
        self.contents << [
            expense.date&.strftime("%d/%m/%y"),
            '',
            report.id,
            'G/L Account',
            '',
            expense.category&.name,
            expense.amount&.value,
            '',
            'Branch',
            '',
            '',
            '',
            user&.name,
            user&.profile&.employee_id,
            '',
            '',
            '$'
        ]
      end
      self.contents << [
          report.created_at&.strftime("%d/%m/%y"),
          '',
          report.id,
          'G/L Account',
          24111001,
          'Employee claims payable',
          '',
          total_amount,
          'Branch',
          '',
          '',
          '',
          'EMPLOYEE',
          user&.profile&.employee_id,
          '',
          '',
          '$'
      ]
    end
  end
end
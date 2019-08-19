class Personalizer::Adapters::Company164::ExportTemplates164::SettledExpenseTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports

  has_scope :filter_date, using: [:from, :to], type: :hash

  def pre_validate

  end

  def init
    users = user.company.users
    self.reports = Report.where(user_id: users.pluck(:id)).processed.includes({user: :profile},expenses:[:category,:amount])
    self.reports = apply_scopes(self.reports, params)

    self.headers = [
        'Account',
        'Sub Account',
        'Department',
        'Cost center',
        'TAX',
        'Base Amount',
        'Debit',
        'Credit',
        'Comments',
        'Supplier',
        'Reference Code',
        'SAC',
        'Ref. Invoice No.'
    ]
    self.contents = []
    count = 1
    reports.each do |report|
      report.expenses.each do |expense|
        self.contents << [
            expense.category.gl_code,
            '',
            report.user.gl_config&.dig(:location_code),
            report.user.gl_config&.dig(:cost_center),
            '',
            '',
            expense.amount.value,
            '',
            '',
            '',
            "Report ID #{report.id}",
            '',
            '',
        ]
      end
      self.contents << [
          '',
          report.user&.profile&.employee_id,
          report.user.gl_config&.dig(:location_code),
          report.user.gl_config&.dig(:cost_center),
          '',
          report.submitted_amount&.value,
          '',
          '',
          '',
          '',
          "Report ID #{report.id}",
          '',
          ''
      ]
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
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
        'Sl. No.',
        'Journal Code',
        'Period',
        'Voucher Date',
        'Description',
        'Account',
        'Sub Account',
        'Department',
        'Cost Center',
        'Tax',
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
      total_amount = 0
      report.expenses.each do |expense|
        total_amount += expense&.amount&.value
        self.contents << [
            count,
            'jv',
            expense.date&.strftime("%y-%m"),
            expense.date&.strftime("%d/%m/%y"),
            "Exps Reimb. For emp code-#{report.user&.profile&.employee_id}",
            expense.category.gl_code,
            '',
            "'#{report.user.gl_config&.dig(:location_code)}",
            report.user.gl_config&.dig(:cost_center),
            '',
            '',
            expense.amount.value&.round(2),
            '',
            '',
            '',
            '',
            '',
            '',
        ]
      end
      self.contents << [
          count,
          'jv',
          report.expenses.last.date&.strftime("%y-%m"),
          report.expenses.last.date&.strftime("%d/%m/%y"),
          "Exps Reimb. For emp code-#{report.user&.profile&.employee_id}",
          31352001,
          '',
          '',
          '',
          '',
          '',
          '',
          total_amount&.round(2),
          '',
          report.user&.profile&.employee_id,
          '',
          '',
          ''
      ]
      count +=1
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
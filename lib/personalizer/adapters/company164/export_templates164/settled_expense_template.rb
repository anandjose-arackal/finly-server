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
    reports.each do |report|
      total_amount = 0
      report.expenses.each do |expense|
        total_amount += expense&.amount&.value
        self.contents << [
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
            "Report ID #{report.id}",
            '',
            '',
        ]
      end
      self.contents << [
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
    end
  end


end
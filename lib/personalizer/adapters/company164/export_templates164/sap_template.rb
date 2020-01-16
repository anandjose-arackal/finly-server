class Personalizer::Adapters::Company164::ExportTemplates164::SapTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports

  def pre_validate

  end

  def init
    users = user.company.users
    self.reports = Report.where(user_id: users.pluck(:id)).processed.includes({user: :profile},expenses:[:category,:amount])
    self.reports = apply_scopes(self.reports, params)

    self.headers = [
        'S. NO.',
        'Report ID',
        'Voucher Type',
        'Period',
        'Voucher Date',
        'Description',
        'Invoice amount',
        'Invoice Number',
        'Invoice Date',
        'Invoice Type',
        'State',
        'Supplier GSTN',
        'Place Of Supply',
        'Account',
        'Sub Account',
        'Department',
        'Cost Center',
        'Tax',
        'Tax Exemption(%)',
        'Base Amount',
        'Debit',
        'Credit',
        'Comments',
        'Supplier',
        'Reference Code',
        'SAC',
        'Ref. Invoice No.',
        'Payment_Mode',
    ]
    self.contents = []
    sl_no = 1
    reports.each do |report|
      total_amount = 0
      report.expenses.each do |expense|
        total_amount += expense&.amount&.value
        user = report.user
        self.contents << [
            sl_no,
            report.id,
            'JV',
            report.submitted_at.strftime("%Y%m"),
            expense.date.strftime("%d/%m/%Y"),
            "Being expenses settled against report ID #{report.id} of #{report.user.name} with #{report.user.employee_id}",
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            expense.category.gl_code,
            '',
            "#{report.user.gl_config&.dig(:location_code)}",
            report.user.gl_config&.dig(:cost_center),
            '',
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
          sl_no,
          report.id,
          'JV',
          report.submitted_at.strftime("%Y%m"),
          report.submitted_at.strftime("%d/%m/%Y"),
          "Being expenses settled against report ID #{report.id} of #{report.user.name} with #{report.user.employee_id}",
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          31352001,
          '',
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
      sl_no += 1
    end
  end

  def invoice_number(expence)
    expence.custom_fields.map { |cf| cf.string_value if cf.field_key == 'invoice_number' }&.first
  end


  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
class Personalizer::Adapters::Company164::ExportTemplates164::SapTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports,:categories

  def init
    users = user.company.users
    self.reports = Report.where(user_id: users.pluck(:id)).processed.includes({user: :profile},expenses:[:category,:amount])
    self.reports = apply_scopes(self.reports, params)
    self.categories = user.company.categories

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
            expense.amount.value,
            expense.date.strftime("%d/%m/%Y"),
            'I',
            '',
            '',
            '',
            '',
            retrieve_account(expense),
            retrieve_sub_account(expense),
            "#{report.user.gl_config&.dig(:location_code)}",
            report.user.gl_config&.dig(:cost_center),
            '',
            '',
            '',
            expense.amount.value&.round(2),
            '',
            'Finly',
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
          'Finly',
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

  def retrieve_account(expense)
    parent_category_id = expense.category&.ancestry
    if parent_category_id.present?
      parent = self.categories.find(parent_category_id.to_i)
    else
      parent = expense.category
    end
    parent.gl_code
  end

  def retrieve_sub_account(expense)
    expense.category&.gl_code
  end


  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
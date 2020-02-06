class Personalizer::Adapters::Company2::ExportTemplates2::SapTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports, :categories

  def init
    users = user.company.users
    self.reports = Report.where(user_id: users.pluck(:id)).processed.includes({user: :profile},expenses:[:category,:amount],report_processor_group_mapping:[:payment] )
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
        'Payment Mode',
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
            {value: expense.date, type: 'date'},
            "Being expenses settled against report ID #{report.id} of #{report.user.name} with #{report.user.employee_id}",
            expense.amount.value,
            '',
            {value: expense.date, type: 'date'},
            'I',
            '',
            '',
            '',
            retrieve_account(expense),
            retrieve_sub_account(expense),
            {value: (report.user.gl_config&.dig(:location_code).present? ? sprintf("%05d", report.user.gl_config&.dig(:location_code)) : ''), type: "string"},
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
          {value: report.submitted_at, type: 'date'},
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
      if [ReportStatus.settled_id, ReportStatus.settlement_confirmed_id].include?(report.report_status_id)
        if report.report_processor_group_mapping&.payment.present?
          payment = report.report_processor_group_mapping.payment
          self.contents << [
              sl_no,
              report.id,
              'BP',
              {value: report.submitted_at, type: 'date'},
              report.submitted_at.strftime("%Y%m"),
              "Being Payment made against various Payment IDs #{payment.id}",
              payment.amount.value,
              '',
              payment.date.strftime("%d/%m/%Y"),
              '',
              '',
              '',
              '',
              '31352001',
              '',
              '',
              '',
              '',
              '',
              '',
              payment.amount.value&.round(2),
              '',
              'Finly',
              '',
              '',
              '',
              '',
          ]
          self.contents << [
              sl_no,
              report.id,
              'BP',
              {value: report.submitted_at, type: 'date'},
              {value: report.submitted_at, type: 'date'},
              "Being Payment made against various Payment IDs #{payment.id}",
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '61110004',
              '9992',
              '',
              '',
              '',
              '',
              '',
              '',
              payment.amount.value&.round(2),
              'Finly',
              payment&.reference_resource&.bank_reference_number,
              '',
              '',
              ''
          ]
        end
      end
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
      return "#{parent.gl_code}"
    else
      return "#{expense.category&.gl_code}"
    end
  end

  def retrieve_sub_account(expense)
    "#{expense.category&.gl_code}"
  end

end
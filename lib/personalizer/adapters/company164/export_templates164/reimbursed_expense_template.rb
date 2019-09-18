class Personalizer::Adapters::Company164::ExportTemplates164::ReimbursedExpenseTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :report_processor_group

  has_scope :filter_completed_date, using: [:from, :to], type: :hash

  def pre_validate

  end

  def init
    self.report_processor_group = user.company.report_processor_groups.where(payment_type: %w(bank_transfer payment_file)).includes(mappings:[:amount,reports: [{user: :profile}]])
    report_processor_group = apply_scopes(self.report_processor_group, params)

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
    report_processor_group.each do |rpg|
      count = 1
      rpg.mappings.each do |rpg_mapping|
            report = rpg_mapping&.reports&.first
            next if report.blank?
            self.contents << [
                count,
                'jv',
                report.expenses.last.date&.strftime("%y-%m"),
                report.expenses.last.date&.strftime("%d/%m/%y"),
                "Exps Reimb. For emp code-#{report.user&.profile&.employee_id}",
                '31352001',
                '',
                "'#{report.user.gl_config&.dig(:location_code)}",
                report.user.gl_config&.dig(:cost_center),
                '',
                '',
                rpg_mapping.amount&.value,
                '',
                '',
                report.user&.profile&.employee_id,
                '',
                '',
                '',
            ]
          self.contents << [
              count,
              'jv',
              report.expenses.last.date&.strftime("%y-%m"),
              report.expenses.last.date&.strftime("%d/%m/%y"),
              "Exps Reimb. For emp code-#{report.user&.profile&.employee_id}",
              '61110004',
              '9992',
              '',
              '',
              '',
              '',
              '',
              rpg_mapping.amount&.value,
              '',
              '',
              '',
              '',
              ''
          ]
        count +=1
      end
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
class Personalizer::Adapters::Company164::ExportTemplates164::ReimbursedExpenseTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :report_processor_group

  has_scope :filter_completed_date, using: [:from, :to], type: :hash

  def pre_validate

  end

  def init
    self.report_processor_group = user.company.report_processor_groups.where(payment_type: %w(bank_transfer payment_file)).includes(mappings: [reports: [{user: :profile},expenses:[:category,:amount]]])
    report_processor_group = apply_scopes(self.report_processor_group, params)

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
    report_processor_group.each do |rpg|
      rpg.mappings.each do |rpg_mapping|
        rpg_mapping.reports.each do |report|
          report.expenses.map do |expense|
            next unless expense.reimbursable
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
                report.user&.profile&.employee_id,
                '',
                '',
                '',
            ]
          end
          self.contents << [
              '61110004',
              '9992',
              '',
              '',
              '',
              '',
              '',
              report.reimbursable_expenses_total&.value,
              '',
              '',
              '',
              '',
              ''
          ]
        end
      end
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
class Personalizer::Adapters::Company164::ExportTemplates164::ReimbursedExpenseTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :report_processor_group

  has_scope :filter_completed_date, using: [:from, :to], type: :hash

  def pre_validate

  end

  def init
    self.report_processor_group = user.company.report_processor_groups.where(payment_type: %w(bank_transfer payment_file)).includes(mappings:[:amount,reports: [{user: :profile}]])
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
            report = rpg_mapping&.reports&.first
            next if report.blank?
            self.contents << [
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
      end
    end
  end

 end
class Personalizer::Adapters::Company2::ExportTemplates2::TallyJournalTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports

  has_scope :filter_approved_date, using: [:from, :to], type: :hash


  def pre_validate

  end

  def init
    users = user.company.users
    self.reports = Report.where(user_id: users.pluck(:id)).settlement_viewable
    self.reports = apply_scopes(self.reports, params)
    self.reports = self.reports.includes({user: :profile}, {dlrms: [:reviewer, :action_taken_by, :forwarded_by]}, expenses: [:category, :amount, {manual_expense: [custom_fields: [:value]]}, {card_expense: [custom_fields: [:value]]}, {distance_expense: [custom_fields: [:value]]}, {time_expense: [custom_fields: [:value]]}])

    self.headers = [
        'VOUCHER Type Name',
        'Voucher No.',
        'Voucher Date',
        'Invoice Ref. No',
        'Invoice Ref. Date',
        'HSN/SAC',
        'Bill Ref. Name',
        'Ledger Name',
        'Cost Centre Name',
        'Amount',
        'Inst. No',
        'Inst. Date',
        'Narration'
    ]

    self.contents = []
    reports.each do |report|
      narration = print_narration(report)
      report.expenses.each do |expense|
        self.contents << [
            'JOURNAL',
            report.id,
            Date.today.strftime('%d-%b'),
            report.id,
            Date.today.strftime('%d/%m/%Y'),
            '',
            '',
            print_ledger_name(expense),
            print_department(expense),
            '%.2f' % expense.amount.value,
            '',
            '',
            narration
        ]
      end
      report.expenses.each do |expense|
        self.contents << [
            'JOURNAL',
            report.id,
            Date.today.strftime('%d-%b'),
            report.id,
            Date.today.strftime('%d/%m/%Y'),
            '',
            '',
            expense.user&.profile&.employee_id,
            '',
            '%.2f' % (expense.amount.value * -1),
            '',
            '',
            ''
        ]
      end
    end
  end

  def print_department(expense)
    expense.custom_fields.map {|cf| cf.string_value if cf.field_key == 'department'}&.first
  end

  def print_market(expense)
    expense.custom_fields.map {|cf| cf.string_value if cf.field_key == 'market'}&.first
  end

  def print_hostel(expense)
    expense.custom_fields.map {|cf| cf.string_value if cf.field_key == 'hostel'}&.first
  end

  def print_city(expense)
    expense.custom_fields.map {|cf| cf.string_value if cf.field_key == 'city'}&.first
  end

  def print_ledger_name(expense)
    "#{gl_code(expense)}-#{expense.category&.name}"
  end

  def print_cost_center(expense)
    hostel_name = print_hostel(expense)
    if hostel_name.present?
      return "#{hostel_name} Hostel"
    end

    city = print_city(expense)
    if city.present?
      return "#{hostel_name} City"
    end

    department = print_department(expense)
    if department.present?
      return "#{department} Department"
    end
  end

  def print_narration(report)
    approved_by = retrieve_approved_by(report)
    "Being Exp of #{report&.expenses&.first&.user&.name} Approved by #{approved_by} Against Report ID# #{report.id}"
  end

  def retrieve_approved_by(report)
    return '' if report.dlrms.blank?
    dlrm = report.dlrms.where(action_id: TrailAction.id_for(:approve), level_number: 2).last
    if dlrm&.taken_control_by_id&.present?
      return dlrm.taken_control_by&.name
    elsif dlrm&.forwarded_by_id&.present?
      return dlrm&.forwarded_by&.name
    elsif dlrm&.reviewer_id.present?
      return dlrm.reviewer&.name
    end
    ''
  end

  STANZA_INDIRECT_GL_CODE_MAPPING = {
      "210004": 321006,
      "202005": 321002,
      "221001": 321001,
      "217002": 306003,
      "211002": 321004,
      "321005": 321003,
      "211004": 333006,
      "217003": 306005,
      "216001": 305001,
      "210003": 321005
  }

  def gl_code(expense)
    gl = expense.category.gl_code
    return gl unless STANZA_INDIRECT_GL_CODE_MAPPING.keys.include?(gl)
    return gl unless expense.report.policy.name.downcase.include?('indirect')
    STANZA_INDIRECT_GL_CODE_MAPPING[gl]
  end


  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
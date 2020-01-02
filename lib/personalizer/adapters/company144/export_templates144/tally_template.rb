class Personalizer::Adapters::Company144::ExportTemplates144::TallyTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :reports

  has_scope :filter_approved_date, using: [:from, :to], type: :hash


  def pre_validate

  end

  def init
    users = user.company.users
    self.reports = Report.where(user_id: users.pluck(:id)).settlement_viewable
    self.reports = apply_scopes(self.reports, params)
    self.reports = self.reports.includes({user: :profile},expenses:[:category,:amount,:custom_fields,{manual_expense:[:custom_fields]},{card_expense:[:custom_fields]},{distance_expense:[:custom_fields]},{time_expense:[:custom_fields]}])

    self.headers = [
        'GL Code',
        'Employee Name',
        'Employee Email',
        'Report ID',
        'Report Name',
        'Policy Name',
        'Amount',
        'Date',
        'Merchant',
        'Spend Account',
        'Category',
        'Department',
        'Market Name',
        'Hostel',
        'City'
    ]

    self.contents = []
    reports.each do |report|
      report.expenses.each do |expense|
        self.contents << [
            gl_code(expense),
            report.user.name,
            report.user.email,
            report.id,
            report.name,
            report.policy.name,
            expense.amount.value,
            expense.date,
            expense.merchant_name,
            expense.spent_from.name,
            expense.category.name,
            print_department(expense),
            print_market(expense),
            print_hostel(expense),
            print_city(expense)
        ]
      end
    end
  end

  def print_department(expense)
    expense.custom_fields.map { |cf| cf.configured_field_value if cf.field_key == 'department' }&.first
  end

  def print_market(expense)
    expense.custom_fields.map { |cf| cf.configured_field_value if cf.field_key == 'market' }&.first
  end

  def print_hostel(expense)
    expense.custom_fields.map { |cf| cf.configured_field_value if cf.field_key == 'hostel' }&.first
  end

  def print_city(expense)
    expense.custom_fields.map { |cf| cf.configured_field_value if cf.field_key == 'city' }&.first
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
class Personalizer::Adapters::Company112::ExportTemplates112::SapTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents

  def pre_validate

  end

  def init
    users = user.company.users
    reports = Report.where(user_id: users.pluck(:id)).processed
    self.headers = [
        'SAP Employee ID',
        'Date',
        'Grade',
        'Amount',
        'Bus.Place',
        'Plant',
        'Cost Center',
        'Profit Center',
        'GL Code',
        'Text'
    ]
    self.contents = []
    count = 1
    reports.each do |report|
      report.expenses.each do |expense|
        self.contents << [
            '',
            expense.date,
            '',
            expense.amount.value,
            expense.merchant_name,
            '',
            '',
            '',
            expense.category&.gl_code,
            ''
        ]
        count += 1
      end
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
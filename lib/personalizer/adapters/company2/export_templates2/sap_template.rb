class Personalizer::Adapters::Company2::ExportTemplates2::SapTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents

  def pre_validate

  end

  def init
    users = user.company.users
    reports = Report.where(user_id: users.pluck(:id)).processed
    self.headers = [
        'Vendor Number',
        'Doc Date',
        'Ref Doc no',
        'Amount',
        'Text',
        'G/L code',
        'Debit / Crd Ind',
        'Amount',
        'Text1',
        'cost center',
        'profit center',
        'count'
    ]
    self.contents = []
    count = 1
    reports.each do |report|
      report.expenses.each do |expense|
        self.contents << [
            expense.merchant_name,
            expense.date,
            expense.id,
            expense.amount.value,
            '',
            "GLCODE_#{expense.category.id}",
            'Debit',
            expense.amount.value,
            '',
            'Cost Center 1',
            'Profit Center 1',
            count
        ]
        count += 1
      end
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
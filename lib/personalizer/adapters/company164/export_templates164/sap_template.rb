class Personalizer::Adapters::Company164::ExportTemplates164::SapTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents

  def pre_validate

  end

  def init
    users = user.company.users
    reports = Report.where(user_id: users.pluck(:id)).processed.includes(:user,expenses:[:category,{manual_expense:[custom_fields: [:value]]},{card_expense:[custom_fields: [:value]]},{distance_expense:[custom_fields: [:value]]},{time_expense:[custom_fields: [:value]]},:amount])
    self.headers = [
        'Account',
        'Department',
        'Cost center',
        'Debit',
        'Credit',
        'Comments',
        'Supplier',
        'Ref Invoice Number'
    ]
    self.contents = []
    count = 1
    reports.each do |report|
      report.expenses.each do |expense|
        self.contents << [
            expense.category.gl_code,
            expense.user.gl_config&.dig(:department_code),
            expense.user.gl_config&.dig(:cost_center),
            expense.amount.value,
            '',
            expense.note,
            expense.merchant_name,
            invoice_number(expense)
        ]
      end
    end
  end

  def invoice_number(expence)
    expence.custom_fields.map { |cf| cf.string_value if cf.field_key == 'invoice_number' }&.first
  end


  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end
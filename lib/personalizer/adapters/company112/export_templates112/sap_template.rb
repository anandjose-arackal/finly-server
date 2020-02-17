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
            sap_id(expense.user),
            expense.date,
            grade(expense.user),
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


  def profit_center(user)
    user.gl_config&.dig(:"New Profit centre")
  end

  def cost_center(user)
    user.gl_config&.dig(:"New Cost Centre")
  end

  def sap_id(user)
    user.gl_config&.dig(:"SAP ID")
  end

  def grade(user)
    ''
  end

  def plant(user)
    ''
  end

end
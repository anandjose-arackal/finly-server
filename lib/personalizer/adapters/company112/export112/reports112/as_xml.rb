class Personalizer::Adapters::Company112::Export112::Reports112::AsXml < Personalizer::Adapters::Base

  attr_accessor :default_headers, :reports

  def init
    self.op_instance.column_names = consul_column_names
  end

  def process
    data = []
    self.reports = self.op_instance.reports
    index = 1
    self.reports.each do |report|
      report.expenses.each do |expense|
        data << [
            index,
            expense.report_id,
            expense.user.employee_id,
            sap_id(expense.user),
            expense.user.name,
            expense.merchant_name,
            expense.date,
            expense.category_name,
            expense.category&.gl_code,
            profit_center(expense.user),
            cost_center(expense.user),
            expense.expense_status&.name.humanize,
            expense.amount&.currency&.country_code,
            expense.amount&.value
        ]
        index += 1
      end
    end
    self.op_instance.data = data
  end

  private

  def consul_column_names
    [
        "S. No",
        "ID",
        "Employee ID",
        "SAP ID",
        "Employee Name",
        "Expense Merchant",
        "Expense Date",
        "Expense Category Name",
        "Expense GL",
        "Profit Center",
        "Cost Center",
        "Status",
        "Expense Currency",
        "Expense Amount"
    ]
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

end

class Personalizer::Adapters::Company112::Export112::Reports112::AsCsv < Personalizer::Adapters::Base

  attr_accessor :default_headers, :reports, :result, :column_names

  def init

  end

  def process
    data = []
    self.reports = self.op_instance.reports
    index = 1
    self.result = CSV.generate do |csv|
      csv << consul_column_names
      self.reports.each do |r|
        r.expenses.each do |expense|
          data = [
              index,
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
          csv << data
        end
      end
    end
    self.op_instance.result = self.result
  end

  private

  def consul_column_names
    [
        "S. No",
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

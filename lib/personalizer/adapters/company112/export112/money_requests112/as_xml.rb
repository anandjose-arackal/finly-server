class Personalizer::Adapters::Company112::Export112::MoneyRequests112::AsXml < Personalizer::Adapters::Base

  attr_accessor :default_headers, :money_requests

  def init
    self.op_instance.column_names = consul_column_names
  end

  def process
    data = []
    self.money_requests = self.op_instance.money_requests
    index = 1
    self.money_requests.each do |money_request|
      money_request.items.each do |money_request_item|
        data << [
            index,
            money_request.user.employee_id,
            sap_id(money_request.user),
            money_request.user.name,
            "",
            money_request.approved_at&.strftime("%Y-%m-%d"),
            money_request_item.category&.name,
            money_request_item.category&.gl_code,
            profit_center(money_request.user),
            cost_center(money_request.user),
            money_request.status&.name&.humanize,
            money_request_item&.amount&.currency&.country_code,
            money_request_item.amount&.value
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

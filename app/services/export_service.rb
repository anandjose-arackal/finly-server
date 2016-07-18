class ExportService < BaseService
  attr_accessor :company

  def initialize(company)
    super()
    self.company = company
  end

  def export_as_csv(report)
    errors.clear
    if report.blank?
      errors << 'No reports selected to export'
      return false
    end
    if report.is_a?(Report)
      report = [report]
    end
    preferences = company.export_preferences
    column_names = preferences.pluck(:name)
    CSV.generate do |csv|
      csv << column_names
      report.each do |r|
        r.expenses.each do |e|
          csv << retrieve_data(preferences, r, e)
        end
      end
    end
  end

  # def export_as_xls(report)
  #   errors.clear
  #   if report.blank?
  #     errors << 'No reports selected to export'
  #     return false
  #   end
  #   if report.is_a?(Report)
  #     report = [report]
  #   end
  #   preferences = company.export_preferences
  #   column_names = preferences.pluck(:name)
  #   CSV.generate do |csv|
  #     csv << column_names
  #     report.each do |r|
  #       r.expenses.each do |e|
  #         csv << retrieve_data(preferences, r, e)
  #       end
  #     end
  #   end
  # end

  # Export as excel format: http://railscasts.com/episodes/362-exporting-csv-and-excel?autoplay=true
  #   <?xml version="1.0"?>
  #       <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
  #   xmlns:o="urn:schemas-microsoft-com:office:office"
  #   xmlns:x="urn:schemas-microsoft-com:office:excel"
  #   xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  #   xmlns:html="http://www.w3.org/TR/REC-html40">
  #   <Worksheet ss:Name="Sheet1">
  #   <Table>
  #   <Row>
  #   <Cell><Data ss:Type="String">ID</Data></Cell>
  #   <Cell><Data ss:Type="String">Name</Data></Cell>
  #   <Cell><Data ss:Type="String">Release Date</Data></Cell>
  #   <Cell><Data ss:Type="String">Price</Data></Cell>
  #   </Row>
  #     <% @products.each do |product| %>
  #       <Row>
  #         <Cell><Data ss:Type="Number"><%= product.id %></Data></Cell>
  #         <Cell><Data ss:Type="String"><%= product.name %></Data></Cell>
  #         <Cell><Data ss:Type="String"><%= product.released_on %></Data></Cell>
  #         <Cell><Data ss:Type="Number"><%= product.price %></Data></Cell>
  #       </Row>
  #   <% end %>
  # </Table>
  #   </Worksheet>
  # </Workbook>

  private
  def retrieve_data(preferences, report, expense)
    data_arr = []
    user = report.user
    preferences.each do |pref|
      case pref.export_field_id
        when ExportField.type_report_id
          data_arr << report.id
        when ExportField.type_report_name
          data_arr << report.name
        when ExportField.type_report_status
          data_arr << report.status.name
        when ExportField.type_employee_name
          data_arr << user.name
        when ExportField.type_employee_id
          data_arr << user.employee_id
        when ExportField.type_payroll_id
          data_arr << user.payroll_id
        when ExportField.type_expense_id
          data_arr << expense.id
        when ExportField.type_expense_merchant
          data_arr << expense.merchant_name
        when ExportField.type_expense_category_name
          data_arr << expense.category_name
        when ExportField.type_expense_currency
          data_arr << expense.amount.currency.country_code
        when ExportField.type_expense_amount
          data_arr << expense.amount.value
        when ExportField.type_expense_date
          data_arr << expense.date
        else
          data_arr << ''
      end
    end
    data_arr
  end

end
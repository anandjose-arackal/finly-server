class Personalizer::Adapters::Company1::ExportTemplates1::Quickbooks < Personalizer::Adapters::ExportBase

  def pre_validate

  end

  def success
    headers = ['quickbooks_report', 'quickbooks_username', 'quickbooks_expense']
    contents = [['quickbooks_report_1', 'quickbooks_user_2', 'quickbooks_expense_3']]
    Exporter.new(user, {spreadsheet: {headers: headers, contents: contents}}, messages)
  end

  # class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter
  #
  #   def render(controller)
  #     controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
  #   end
  #
  # end

end
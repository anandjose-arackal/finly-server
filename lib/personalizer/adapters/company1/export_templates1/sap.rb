class Personalizer::Adapters::Company1::ExportTemplates1::Sap < Personalizer::Adapters::ExportBase

  def pre_validate

  end

  def success
    headers = ['sap_report', 'sap_username', 'sap_expense']
    contents = [['sap_report_1', 'sap_user_2', 'sap_expense_3']]
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
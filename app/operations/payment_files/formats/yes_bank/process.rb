class PaymentFiles::Formats::YesBank::Process < PaymentFiles::Formats::BaseFormat

  def pre_validate
    super
    return if has_errors?
    unless user.company.payment_file_configuration&.payload&.dig(:customer_code).present?
      add_message :error, 'Custom code for Yes Bank has not been configured'
      return
    end
  end

  def validate
    super
    unless self.options&.dig(:customer_code).present?
      add_message :error, 'Customer Code is not configured for YesBank Payment File'
      return
    end
  end

  def process
    headers = ['report', 'username', 'expense']
    contents = [['report_1', 'user_2', 'expense_3']]
    Exporter.new(user, {spreadsheet: {headers: headers, contents: contents}}, messages)
    # template = "#{File.expand_path(File.dirname(__FILE__))}/template.xls.erb"
    # customer_code = user.company.payment_file_configuration&.options&.dig(:customer_code)
    # total_amount = ''
    # contents = []
    # Exporter::Spreadsheet.new(user, {template: template, contents: contents, data: {customer_code: customer_code, total: total_amount}})
  end

end
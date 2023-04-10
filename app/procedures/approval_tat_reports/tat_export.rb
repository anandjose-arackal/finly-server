class ApprovalTatReports::TatExport < Transactions::API

  include Transactions::BackgroundWorker
  include Writexlsx::Utility
  include ApprovalTatReports::TatHelper

  sidekiq_options retry: 0

  step :tat_reports_data
  step :build_report_export_send_mail
  fail :send_mail_data_not_found

  def tat_reports_data(options, params:, current_user:, **)
    params[:paginate] = false
    result = IndexBuilder::Show.(params: params, current_user: current_user)
    return false  unless result['model.records'].present?
    options[:spreadsheet_data] = export_report(result['model.records'], params.dig(:route))
    true
  end

  def build_report_export_send_mail(options, params:, current_user:, **)
    file = Tempfile.new(["#{params.dig(:route)}_approval_tat_reports", '.xlsx'])
    workbook = ::WriteXLSX.new(file)
    worksheet = workbook.add_worksheet('Sheet 1')

    headers = options[:spreadsheet_data].dig(:meta,:max_columns)
    headers.each_with_index do |header, i|
      worksheet.write(0, i, header)
    end
    
    options[:spreadsheet_data].dig(:data).each_with_index do |row, row_index|
      max_columns = options[:spreadsheet_data].dig(:meta,:max_columns)
      row_data = []
      max_columns.each do |each_column|
        if row.key?(each_column)
          row_data << row[each_column]
        else
          row_data << "-"
        end
      end
      row_data.each_with_index do |cell_data, col_index|
        worksheet.write(row_index + 1, col_index, cell_data)
      end
    end

    workbook.close
    file.rewind

    subject = "#{params.dig(:route).titleize} tat file  generated at #{DateTime.now.strftime("%d-%m-%Y %T")}"
    body = "You have a new notification on Finly"
    ApprovalTatReportsMailer.delay.send_mail(current_user.email, subject, body, "#{params.dig(:route)}_approval_tat_reports.xlsx", file.path)
    true
  end

  def send_mail_data_not_found(options, params:, current_user:, **)
    subject = "#{params.dig(:route).titleize} tat file from Finly"
    body = "Failed to generate tat report"
    ApprovalTatReportsMailer.delay.send_mail(current_user.email, subject, body, nil, nil)
    true
  end

end
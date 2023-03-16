class ApprovalTatReports::TatExport < Transactions::API

  include Transactions::BackgroundWorker
  include Writexlsx::Utility
  include ApprovalTatReports::TatHelper

  sidekiq_options queue: :payments_queue
  
  step :tat_reports_data
  step :build_report_export
  step :send_report_to_user

  def tat_reports_data(options, params:, **)
    result = IndexBuilder::Show.(params)
    options[:spreadsheet_data] = export_report(result['model.records'], params.dig(:route))
    options[:file_name] = params.dig(:route)
    true
  end

  def build_report_export(options, params:, **)
    workbook = WriteXLSX.new("#{options[:file_name]}_approval_tat_reports.xlsx")
    worksheet = workbook.add_worksheet('Sheet 1')

    headers = options[:spreadsheet_data].dig(:meta,:max_columns)
    headers.each_with_index do |header, i|
      worksheet.write(0, i, header)
    end

    options[:spreadsheet_data].dig(:data).each_with_index do |row, row_index|
      row_data = row.values.take(options[:spreadsheet_data].dig(:meta,:max_columns).count)
      row_data.each_with_index do |cell_data, col_index|
        worksheet.write(row_index + 1, col_index, cell_data)
      end
    end

    params[:attachment] = workbook

    workbook.close
    true
  end

  def send_report_to_user(options, params:, **)
    subject = "#{params.dig(:route).capitalize} tat file from Finly"
    body =  "You have a new notification on Finly"
    ApprovalTatReportsMailer.send_mail(email: params[:current_user].email, subject: subject, body: body, file: params[:attachment]).deliver_later
  end

end
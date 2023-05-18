class ApprovalTatReports::TatExport < Transactions::API

  include Transactions::BackgroundWorker
  include Writexlsx::Utility
  include ApprovalTatReports::TatHelper

  sidekiq_options retry: 0

  step :find_builder
  step :tat_reports_data
  step :build_report_export_send_mail
  fail :send_mail_data_not_found

  def find_builder(context, params:, **)
    route = IndexBuilder::Router[params.dig(:route)]&.first
    context[:builder] = route.klass
    true
  end

  def tat_reports_data(context, builder:, params:, current_user:, **)
    RequestStoreUtil.set_current_user(current_user)
    result = builder.resolve(context, paginate: false)
    return false  unless result['model.records'].present?
    context[:spreadsheet_data] = export_report(result['model.records'], params.dig(:route))
    true
  end

  def build_report_export_send_mail(context, params:, current_user:, **)
    file = Tempfile.new(["#{params.dig(:route)}_approval_tat_reports", '.xlsx'])
    workbook = ::WriteXLSX.new(file)
    worksheet = workbook.add_worksheet('Sheet 1')

    headers = context[:spreadsheet_data].dig(:meta,:max_columns)
    headers.each_with_index do |header, i|
      worksheet.write(0, i, header)
    end
    
    context[:spreadsheet_data].dig(:data).each_with_index do |row, row_index|
      max_columns = context[:spreadsheet_data].dig(:meta,:max_columns)
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

    ApprovalTatReportsMailer.delay.send_mail({email: current_user.email, route_name: params.dig(:route), file_path: file.path})
    true
  end

  def send_mail_data_not_found(context, params:, current_user:, **)
    ApprovalTatReportsMailer.delay.send_mail({email: current_user.email, route_name: params.dig(:route)})
    true
  end

end
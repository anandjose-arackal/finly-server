class ExportController < ApplicationController

  def report
    if @admin_view
      @reports = current_user.company.all_reports
    elsif @manager_view or @finance_view
      @reports = current_user.interacted_reports
    else
      @reports = current_user.reports
    end
    unless @reports.present? and params[:report_id].present?
      flash[:failure] = 'Report not found'
      render_flash_message
      return
    end
    reports = @reports.with_id(params[:report_id])
    unless reports.present?
      flash[:danger] = 'Report not found'
      render_flash_message
      return
    end
    es = ExportService.new(current_user.company)
    respond_to do |format|
      format.html
      format.csv { send_data es.export_as_csv(reports) }
      format.xls do
        d = es.export_as_xls(reports)
        @header = d[:header]
        @data = d[:data]
      end
      format.pdf
    end
  end

end

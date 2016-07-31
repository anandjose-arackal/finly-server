class ExportController < ApplicationController

  def report
    role = UserRole.employee_id
    if @admin_view
      role = UserRole.employee_id
    elsif @manager_view
      role = UserRole.manager_id
    elsif @finance_view
      role = UserRole.finance_manager_id
    end
    @reports = ReportService.new(user: current_user).reports(role)
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

class ExportController < ApplicationController
  include MathUtil

  before_action :authenticate_user!

  def report
    role = UserRole.employee_id
    if @admin_view
      role = UserRole.admin_id
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
    report = @reports.find_by_id(params[:report_id])
    unless report.present?
      flash[:danger] = 'Report not found'
      render_flash_message
      return
    end
    es = ExportService.new(current_user.company)
    respond_to do |format|
      format.html
      format.csv { send_data es.export_as_csv(report) }
      format.xls do
        d = es.export_as_xls(report)
        @header = d[:header]
        @data = d[:data]
      end
      format.pdf do
        @comments = report.comments
        load_info_for_views(report)
        render pdf: "report-#{report.name}", layout: "pdf.html.erb" # Excluding ".pdf" extension.
      end

    end
  end

  private

  def load_info_for_views(report)
    @report = report
    uts = UserTeamService.new(report.user)
    manager = uts.manager(report: report)
    if manager.blank?
      manager = uts.finance_manager(report: report)
    end
    @manager_name = nil
    @manager_name = manager.name if manager.present?
    @status = report.relative_status_name(current_user)
    rds = ReportDetailService.new(@report)
    @total = precision_value rds.total_amount
    @date_string = rds.date_as_string
    @policy = report.policy

    # loading expenses
    @expenses= []
    @categories = current_user.company.categories
    all_expenses = @report.expenses
    @categories.each do |category|
      item_expenses = all_expenses.with_category(category.id)
      if item_expenses.present?
        item_name = category.name
        item_sum = precision_value item_expenses.with_amount.sum(:value)
        @expenses << {category_name: item_name, expenses: item_expenses, category_total: item_sum}
      end
    end
  end

end

class ReportsController < ApplicationController
  include MathUtil
  before_action :authenticate_user!

  def create
    fetch_report
    rs = ReportService.new(user: current_user)
    if rs.create
      redirect_to report_path(rs.report)
    end
  end

  def index
    @reports = fetch_reports
    @reports = @reports.paginate(page: params[:page], per_page: 30) if @reports.present?
    @interacted_reports = @interacted_reports.paginate(page: params[:page], per_page: 30) if @interacted_reports.present?
  end

  def update

  end

  def show
    fetch_report
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
    @manager_name = current_user.name
    @comments = @report.comments.all.order(created_at: :desc)
    @status = @report.status.name
    @status = @status[0].upcase + @status[1..@status.length]
    rds = ReportDetailService.new(@report)
    @total = precision_value rds.total_amount
    @date_string = rds.date_as_string
  end

  def destroy

  end

  def add_expenses

  end

  def remove_expenses

  end

  def submit
    fetch_report
    rs = ReportService.new(user: current_user, report: @report)
    if rs.submit
      show
    end
  end

  def retract
    fetch_report
    rs = ReportService.new(user: current_user, report: @report)
    if rs.retract
      show
    end
  end

  def approve
    fetch_report
    rs = ReportService.new(user: current_user, report: @report)
    if rs.approve
      show
    end

  end

  def reject

  end

  def take_control

  end

  def export

  end

  def comment
    fetch_report
    rs = ReportService.new(user: current_user, report: @report)
    rs.comment params[:comment]
    @comments = @report.comments
    respond_to do |format|
      format.html do
        if request.present? && request.referrer.present?
          redirect_to request.referrer
        end
      end
      format.js do
        render partial: 'reports/comments', replace: "#commentsContainer"
      end
      format.json {}
    end
  end

  private
  def fetch_reports
    if @admin_view
      @reports = current_user.company.all_reports
    elsif @manager_view
      @reports = current_user.controlling_reports.non_owner(current_user.id)
      @interacted_reports = current_user.manager_reports
    elsif @finance_view
      @reports = current_user.controlling_reports.non_owner(current_user.id)
      @interacted_reports = current_user.finance_reports
    else
      @reports = current_user.reports
    end
  end

  def fetch_report
    if @admin_view
      @reports = current_user.company.all_reports
    elsif @manager_view or @finance_view
      @reports = current_user.interacted_reports
    else
      @reports = current_user.reports
    end
    return nil unless @reports.present?
    id = params[:report_id]
    if id.blank? and params[:id].present?
      id = params[:id]
    end
    @report = @reports.with_id id, single: true
  end

end
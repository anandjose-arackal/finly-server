class ReportsController < ApplicationController
  include MathUtil
  before_action :authenticate_user!
  before_action :fetch_report, except: [:create, :index, :export]
  before_action :fetch_reports, only: [:index]

  def create
    rs = ReportService.new(user: current_user)
    if rs.create
      redirect_to report_path(rs.report)
      return
    end
    flash[:error] = rs.errors
    render_flash_message
  end

  def index
    @reports = @reports.paginate(page: params[:page], per_page: 30) if @reports.present?
    @interacted_reports = @interacted_reports.paginate(page: params[:page], per_page: 30) if @interacted_reports.present?
  end

  def update

  end

  def show
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
    @views = {}
    if @admin_view
      if @report.can_take_control? and not @report.controlling_user?(current_user)
        @views[:take_control] = true
      end
    elsif @finance_view or @manager_view
      if @report.processing? and @report.controlling_user?(current_user)
        @views[:review] = true
      elsif (@report.can_unapprove?) and @report.associated_users(@report.controlling_user).include?(current_user)
        @views[:unapprove] = true
      end
      if @finance_view and @report.reimbursement_pending?
        @views[:reimburse] = true
      end
    else
      if @report.open? or @report.retracted?
        @views[:add_expenses] = true
        @views[:delete] = true
      elsif @report.processing?
        @views[:retract] = true
      elsif @report.reimbursed?
        @views[:reimbursement_confirm] = true
      end
    end
  end

  def destroy
    rs = ReportService.new(user: current_user, report: @report)
    if rs.delete_report
      flash[:success] = "Report deleted"
      redirect_to reports_path(view: params[:view])
      return
    end
    flash[:danger] = rs.errors
    render_flash_message
  end

  def add_expenses

  end

  def remove_expenses

  end

  def submit
    handle_update :submit, 'Report submitted'
  end

  def retract
    handle_update :retract, 'Report retracted'
  end

  def approve
    handle_update :approve, 'Report approved'
  end

  def reject
    handle_update :reject, 'Report rejected'
  end

  def unapprove
    handle_update :unapprove, 'Report unapproved'
  end

  def take_control
    handle_update :take_control, 'You have taken control of the report'
  end

  def reimburse
    # rs = ReportService.new(user: current_user, report: @report)
    # if rs.reimburse
    #   flash[:success] = 'You have taken control of the report'
    #   redirect_to report_path(rs.report)
    #   return
    # end
    # flash[:danger] = rs.errors
    # render_flash_message
  end

  def reimbursement_confirm
    rs = ReportService.new(user: current_user, report: @report)
    if rs.reimbursement_confirm
      flash[:success] = 'You have taken control of the report'
      redirect_to report_path(rs.report)
      return
    end
    flash[:danger] = rs.errors
    render_flash_message
  end

  def comment
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
        render partial: 'reports/comments', replace: '#commentsContainer'
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
    @reports
  end

  def fetch_report
    controlling_reports = nil
    if @admin_view
      reports = current_user.company.all_reports
    elsif @manager_view or @finance_view
      reports = current_user.interacted_reports
      controlling_reports = current_user.controlling_reports
    else
      reports = current_user.reports
    end
    return nil unless @reports.present? or controlling_reports.present?
    id = params[:report_id]
    if id.blank? and params[:id].present?
      id = params[:id]
    end
    @report = reports.with_id(id)
    if @report.blank? and controlling_reports.present?
      @report = controlling_reports.with_id(id)
    end
    if @report.present?
      @report = @report.first
    else
      @report = nil
    end
    @report
  end

  def view_params
    if @admin_view
      return {view: 'admin'}
    elsif @manager_view
      return {view: 'manager'}
    elsif @finance_view
      return {view: 'finance'}
    end
    nil
  end

  def handle_update(update, success_message)
    rs = ReportService.new(user: current_user, report: @report)
    if rs.send(update)
      flash[:success] = success_message
      redirect_to report_path(rs.report, view_params)
      return
    end
    flash[:danger] = rs.errors
    render_flash_message
  end

end
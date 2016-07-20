class ReportsController < ApplicationController
  include MathUtil
  before_action :authenticate_user!
  before_action :fetch_report, except: [:create, :index, :export]
  before_action :fetch_reports, only: [:index]

  def create
    rs = ReportService.new(user: current_user)
    if rs.create
      redirect_to report_path rs.report, view_params
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
    handle_update :update_report, nil, update_params
  end

  def show
    load_view_for_report
  end

  def destroy
    handle_update :delete_report, 'Report deleted'
  end

  def add_expenses

  end

  def remove_expenses
    handle_update :remove_expense, nil, params[:expense_id]
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
      redirect_to report_path rs.report, view_params
      return
    end
    flash[:danger] = rs.errors
    render_flash_message
  end

  def comment
    rs = ReportService.new(user: current_user, report: @report)
    if rs.comment params[:comment]
      @comments = @report.comments
      if params[:show_flash].present? && params[:show_flash] == 'true'
        flash.now[:success] = 'Comment posted'
      end
      respond_to do |format|
        format.html do
          redirect_to report_path rs.report, view_params
        end
        format.js { render partial: 'reports/comments', replace: '#commentsContainer' }
      end
      return
    end
    flash[:danger] = rs.errors
    render_flash_message
  end

  private
  def load_view_for_report
    load_expenses_for_views
    load_info_for_views
    @comments = @report.comments.all.order(created_at: :desc)
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
      if @report.open? or @report.retracted? or @report.rejected?
        @views[:add_expenses] = true
        @views[:delete] = true
      elsif @report.processing?
        @views[:retract] = true
      elsif @report.reimbursed?
        @views[:reimbursement_confirm] = true
      end
    end
  end

  def load_expenses_for_views
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

  def load_info_for_views
    uts = UserTeamService.new(@report.user)
    manager = uts.manager(report: @report)
    if manager.blank?
      manager = uts.finance_manager(report: @report)
    end
    @manager_name = nil
    @manager_name = manager.name if manager.present?
    @status = @report.relative_status_name(current_user)
    rds = ReportDetailService.new(@report)
    @total = precision_value rds.total_amount
    @date_string = rds.date_as_string
  end

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
    if @interacted_reports.present?
      without_id = @reports.pluck(:id)
      @interacted_reports= @interacted_reports.without_id(without_id)
    end
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
    if reports.blank? and controlling_reports.blank?
      flash[:danger] == 'Report not found'
      redirect_to reports_path(view: params[:view])
      return false
    end
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
    if @report.blank?
      flash[:danger] == 'Report not found'
      redirect_to reports_path(view: params[:view])
      return false
    end
    true
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

  def handle_update(update, success_message, params=nil)
    rs = ReportService.new user: current_user, report: @report
    if (params.present? and rs.send(update, params)) or (params.blank? and rs.send(update))
      flash.now[:success] = success_message unless success_message.blank?
      if update == :delete_report
        redirect_to reports_path view_params
        return
      end
      respond_to do |format|
        format.html do
          redirect_to report_path rs.report, view_params
        end
        format.js do
          load_view_for_report
          render 'reports/report', remote: true
        end
      end
      return
    end
    flash.now[:danger] = rs.errors
    render_flash_message
  end

  def update_params
    params.require(:report).permit(:name, :policy_id)
  end

end
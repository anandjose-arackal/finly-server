class ReportsController < ApplicationController
  include MathUtil
  before_action :authenticate_user!
  before_action :fetch_report, except: [:create, :index, :export]
  before_action :fetch_reports, only: [:index]
  before_action :load_service_object

  has_scope :filter_search
  has_scope :filter_status
  has_scope :filter_user
  has_scope :filter_date, using: [:from, :to], type: :hash
  has_scope :filter_policy

  def create
    authorize Report
    rs = ReportService.new(user: current_user)
    if rs.create create_params
      redirect_to report_path rs.report, view_params
      return
    end
    flash[:error] = rs.errors
    render_flash_message
  end

  def index
    type_counts = @reports.group(:report_status_id).count
    @counts = {}
    @counts[:open] = (type_counts[ReportStatus.open_id] or 0)
    @counts[:processing] = (type_counts[ReportStatus.processing_id] or 0)
    @counts[:retracted] = (type_counts[ReportStatus.retracted_id] or 0)
    @counts[:rejected] = (type_counts[ReportStatus.rejected_id] or 0)
    @counts[:approved] = (type_counts[ReportStatus.approved_id] or 0)
    @counts[:reimbursed] = (type_counts[ReportStatus.reimbursed_id] or 0)
    @counts[:reimbursement_confirmed] = (type_counts[ReportStatus.reimbursement_confirmed_id] or 0)
    @counts[:closed] = (type_counts[ReportStatus.closed_id] or 0)
    generate_filters
    @reports = apply_scopes(@reports).paginate(page: params[:page], per_page: 30) if @reports.present?
  end

  def update
    authorize @report
    handle_update :update_report, nil, update_params
  end

  def show
    authorize @report
    load_view_for_report
  end

  def destroy
    authorize @report
    handle_update :delete_report, 'Report deleted'
  end

  def add_expenses
    authorize @report
    handle_update :add_expense, 'Expenses added to report', params[:expense_id]
  end

  def remove_expenses
    authorize @report
    handle_update :remove_expense, nil, params[:expense_id]
  end

  def submit
    authorize @report
    handle_update :submit, 'Report submitted'
  end

  def retract
    authorize @report
    handle_update :retract, 'Report retracted'
  end

  def approve
    authorize @report
    handle_update :approve, 'Report approved'
  end

  def reject
    authorize @report
    handle_update :reject, 'Report rejected'
  end

  def unapprove
    authorize @report
    handle_update :unapprove, 'Report unapproved'
  end

  def take_control
    authorize @report
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
    authorize @report
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
    authorize @report
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

  def assign_policy
    authorize @report
    handle_update :update_report, 'Policy Updated', update_params
  end

  private
  def create_params
    params.require(:report).permit(:expense_id, :name) if params[:report].present?
  end

  def load_service_object
    @violation_service = ViolationService.new(current_user)
  end

  def load_view_for_report
    load_expenses_for_views
    load_info_for_views
    @comments = @report.comments.all.order(created_at: :desc)
    @views = {}
    if @admin_view
      if @report.can_take_control? and not @report.controlling_user?(current_user)
        @views[:take_control] = true
      elsif @report.processing? and @report.controlling_user?(current_user)
        @views[:review] = true
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
    # code for report policy
    @policies = @report.user.policies
    @policy = PolicyRetrievalService.for_report(@report)
    @violation_messages = @violation_service.violations(@policy, @report)
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
    rs = ReportService.new(user: current_user)
    if @admin_view
      @reports = rs.reports(UserRole.admin_id)
    elsif @manager_view
      @reports = rs.reports(UserRole.manager_id)
    elsif @finance_view
      @reports = rs.reports(UserRole.finance_manager_id)
    else
      @reports = rs.reports(UserRole.employee_id)
    end
    # if @admin_view
    #   rs = ReportService.new(user: current_user)
    #   @reports = rs.admin_reports
    #   unless @reports
    #   flash.now[:danger] = rs.errors
    #   render_flash_message
    #   return false
    #   end
    # elsif @manager_view
    #   @reports = current_user.controlling_reports.non_owner(current_user.id)
    #   @interacted_reports = current_user.manager_reports
    # elsif @finance_view
    #   @reports = current_user.controlling_reports.non_owner(current_user.id)
    #   @interacted_reports = current_user.finance_reports
    # else
    #   @reports = current_user.reports
    # end
    # @reports
    # if @interacted_reports.present?
    #   without_id = @reports.pluck(:id)
    #   @interacted_reports= @interacted_reports.without_id(without_id)
    # end
  end

  def fetch_report
    fetch_reports
    if @reports.blank?
      flash[:danger] == 'Report not found'
      redirect_to reports_path(view: params[:view])
      return false
    end
    id = params[:report_id]
    if id.blank? and params[:id].present?
      id = params[:id]
    end
    @report = @reports.with_id(id)
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

  def generate_filters
    @filter = {}
    if params[:filter_status].present?
      status_id = params[:filter_status]
      status = ReportStatus.find_by(id: status_id)
      @filter[:status] = status.name if status.present?
    end
  end

end
class ReportsController < ApplicationController
  include MathUtil
  before_action :authenticate_user!

  def create
    create_report_op = Report::Create.new(current_user)
    @report = create_report_op.run
    if @report
      # #Calling methods neccessary to render show
      # load_expenses_for_views
      # load_info_for_views
      # @comments = @report.comments.all.order(created_at: :desc)
      @show_presenter = Report::Show.new(current_user, params)

      respond_to do |format|
        #rendeing show method
        format.json {render :show}
      end
      return
    end
    # todo - render error message
  end

  def index
    @result = Report::Index.new(current_user, params).run
    # @counts = @index_presenter.counts

    # @reports = apply_scopes(@reports).paginate(page: params[:page], per_page: 30) if @reports.present?

    respond_to do |format|
      format.html {}
      # format.json { render json: @reports.as_json }
      format.json {}
    end
  end

  def update
    update_op = Report::Update.new(current_user, params)
    if update_op.run
      flash[:success] = "Report updated successfully."
    else
      flash[:failure] = update_op.errors
    end
    load_response
  end

  def show
    @result = Report::Show.new(current_user, params).run
    # load_view_for_report
    # @comments = @report.comments.all.order(created_at: :desc)
    # # ap @actions

    respond_to do |format|
      format.json {}
    end

  end

  def destroy
    destroy_op = Report::Destroy
    if destroy_op.run
      flash.now[:success] = "Report deleted."
      format.json {render :index}
    else
      flash.now[:failure] = destroy_op.errors
    end
    load_response
  end

  def add_expenses
    add_expenses_op = Report::Expenses::Add.new(current_user, params)
    if add_expenses_op.run
      flash.now[:success] = "Expenses added."
    else
      flash.now[:failure] = add_expenses_presenter.errors
    end
    load_response
  end

  def remove_expenses
    remove_expenses_op = Report::Expenses::Remove.new(current_user, params)
    if remove_expenses_op.run
      flash.now[:success] = "Expenses removed"
    else
      flash.now[:failure] = remove_expenses_op.errors
    end
    load_response
  end

  def submit
    submit_op = Report::Submit.new(current_user, params)
    if submit_op.run
      flash.now[:success] = "Report Submitted!"
    else
      flash.now[:failure] = submit_op.errors
    end
    load_response
  end

  def retract
    retract_op = Report::Retract.new(current_user, params)
    if retract_op.run
      flash.now[:success] = "Report retracted."
    else
      flash.now[:failure] = retract_op.errors
    end
    load_response
  end

  def approve
    approve_op = Report::Approve.new(current_user, params)
    if approve_op.run
      flash.now[:success] = "Report approved."
    else
      flash.now[:failure] = approve_op.errors
    end
    load_response
  end

  def reject
    reject_op = Report::Reject.new(current_user, params)
    if reject_op.run
      flash.now[:success] = "Report rejected."
    else
      flash.now[:failure] = reject_op.errors
    end
    load_response
  end

  def reject_expense
    updater = Report::Expenses::Reject.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      flash.now[:success] = 'Expense rejected'
    else
      flash.now[:failure] = updater.errors
    end
    load_response
  end

  def unapprove
    unapprove_op = Report::Unapprove.new(current_user, params)
    if unapprove_op.run
      flash.now[:success] = "Report unapproved."
    else
      flash.now[:failure] = unapprove_op.errors
    end
    load_response
  end

  def take_control
    take_control_op = Report::TakeControl.new(current_user, params)
    if take_control_op.run
      flash.now[:success] = "You've taken control of this report"
    else
      flash.now[:failure] = take_control_op.errors
    end
    load_response
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
    reimburse_confirm_op = Report::ReimburseConfirm.new(current_user, params)
    if reimburse_confirm_op.run
      flash.now[:success] = "Reimbursement confirmed."
    else
      flash.now[:failure] = reimburse_confirm_op.errors
    end
    load_response
  end

  def comment
    comment_op = Report::Comment::Create.new(current_user, params)
    if comment_op.run
      flash.now[:success] = "You've taken control of this report"
    else
      flash.now[:failure] = comment_op.errors
    end
    load_response
  end


  private

  def load_response
    respond_to do |format|
      # format.html do
      #   redirect_to report_path rs.report, view_params
      # end
      format.json do
        @show_presenter = Report::Show.new(current_user, params).run
        render :show
      end
      # format.js do
      #   load_view_for_report
      #   render 'reports/report', remote: true
      # end
    end
  end


  # def load_view_for_report
  #   load_expenses_for_views
  #   load_info_for_views
  #   @comments = @report.comments.all.order(created_at: :desc)
  #   # the below will be replaced by the actions that are possible in the report
  #   # @views = {}
  #   # if @admin_view
  #   #   if @report.can_take_control? and not @report.controlling_user?(current_user)
  #   #     @views[:take_control] = true
  #   #   elsif @report.processing? and @report.controlling_user?(current_user)
  #   #     @views[:team] = true
  #   #   end
  #   # elsif @finance_view or @manager_view
  #   #   if @report.processing? and @report.controlling_user?(current_user)
  #   #     @views[:team] = true
  #   #   elsif (@report.can_unapprove?) and @report.associated_users(@report.controlling_user).include?(current_user)
  #   #     @views[:unapprove] = true
  #   #   end
  #   #   if @finance_view and @report.reimbursement_pending?
  #   #     @views[:reimburse] = true
  #   #   end
  #   # else
  #   #   if @report.open? or @report.retracted? or @report.rejected?
  #   #     @views[:add_expenses] = true
  #   #     @views[:delete] = true
  #   #   elsif @report.processing?
  #   #     @views[:retract] = true
  #   #   elsif @report.reimbursed?
  #   #     @views[:reimbursement_confirm] = true
  #   #   end
  #   # end
  #   @actions = @show_presenter.load_actions
  #   # code for report policy
  #   @policies = @report.user.policies
  #   @policy = @report.versioned_policy
  #   @violation_messages = Report::Violation.new(current_user, {report_id: @report.id, role_id: params[:role_id]})
  # end
  #
  # def load_expenses_for_views
  #   # won't change much even with operations
  #   @expenses= []
  #   @categories = current_user.company.categories
  #   @expenses = @show_presenter.expenses_category_sorted
  # end
  #
  # def load_info_for_views
  #   @manager_name = @show_presenter.manager.name if @show_presenter.manager
  #   @status = @report.relative_status_name(current_user)
  #   @total = precision_value @report.total_amount
  #   @date_string = @report.date_as_string
  # end
  #
  # def fetch_reports
  #
  #   if @admin_view
  #     role_id = UserRole.admin_id
  #   elsif @manager_view
  #     role_id = UserRole.manager_id
  #   elsif @finance_view
  #     role_id = UserRole.finance_manager_id
  #   else
  #     role_id = UserRole.employee_id
  #   end
  #   @index_presenter = Report::Index.new(current_user, role_id: role_id).run
  #   @reports = @index_presenter.reports
  #
  # end
  #
  # def fetch_report
  #   show_op = Report::Show.new(current_user, params)
  #   @show_presenter = show_op.run
  #   @report = @show_presenter.report
  # end
  #
  # def view_params
  #   if @admin_view
  #     return {view: 'admin'}
  #   elsif @manager_view
  #     return {view: 'manager'}
  #   elsif @finance_view
  #     return {view: 'finance'}
  #   end
  #   nil
  # end

  def handle_update(update, success_message, params=nil)
    rs = ReportService.new user: current_user, report: @report
    if (params.present? and rs.send(update, params)) or (params.blank? and rs.send(update))
      flash.now[:success] = success_message unless success_message.blank?
      if update == :delete_report
        # redirect_to reports_path view_params
        respond_to do |format|
          format.json {render json: {"status": "success"}}
        end
        return
      end

      @report = rs.report
      #creating @report for use in show.json.jbuilder

      #Calling methods neccessary to render show
      load_expenses_for_views
      load_info_for_views
      @comments = @report.comments.all.order(created_at: :desc)
      
      respond_to do |format|
        format.html do
          redirect_to report_path rs.report, view_params
        end
        format.json {render :show}
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
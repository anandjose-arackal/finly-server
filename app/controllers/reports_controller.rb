class ReportsController < ApplicationController
  include MathUtil
  before_action :authenticate_user!

  def create
    create_report_op = Report::Create.new(current_user)
    @result = create_report_op.run
    if create_report_op.is_success?
      respond_to do |format|
        format.json do
          render :show
        end
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
    @result = update_op.run
    if update_op.is_success?
      flash[:success] = "Report updated successfully."
    else
      flash[:failure] = update_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def show
    @result = Report::Show.(current_user, params)
    # load_view_for_report
    # @comments = @report.comments.all.order(created_at: :desc)
    # # ap @actions
    debugger
    respond_to do |format|
      format.json {}
    end
  end

  def destroy
    destroy_op = Report::Destroy.new(current_user, params)
    destroy_op.run
    # debugger
    if destroy_op.is_success?
      respond_to do |format|
        # flash.now[:success] = "Report deleted."
        format.json {render json: {"success": true}}
      end
    else
      flash.now[:failure] = destroy_op.errors
    end
    # load_response
  end

  def add_expenses
    add_expenses_op = Report::Expenses::Add.new(current_user, params)
    @result = add_expenses_op.run
    if add_expenses_op.is_success?
      flash.now[:success] = "Expenses added."
    else
      flash.now[:failure] = add_expenses_presenter.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def remove_expenses
    remove_expenses_op = Report::Expenses::Remove.new(current_user, params)
    @result = remove_expenses_op.run
    if remove_expenses_op.is_success?
      flash.now[:success] = "Expenses removed"
    else
      flash.now[:failure] = remove_expenses_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def submit
    submit_op = Report::Submit.new(current_user, params)
    @result = submit_op.run
    # debugger
    if submit_op.is_success?
      flash.now[:success] = "Report Submitted!"
    else
      flash.now[:failure] = submit_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def retract
    retract_op = Report::Retract.new(current_user, params)
    @result = retract_op.run
    if retract_op.is_success?
      flash.now[:success] = "Report retracted."
    else
      flash.now[:failure] = retract_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def approve
    approve_op = Report::Approve.new(current_user, params)
    @result = approve_op.run
    if approve_op.is_success?
      flash.now[:success] = "Report approved."
    else
      flash.now[:failure] = approve_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def reject
    reject_op = Report::Reject.new(current_user, params)
    @result = reject_op.run
    if reject_op.is_success?
      flash.now[:success] = "Report rejected."
    else
      flash.now[:failure] = reject_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def reject_expense
    updater = Report::Expenses::Reject.new(current_user, params)
    @result = updater.run
    if updater.is_success?
      flash.now[:success] = 'Expense rejected'
    else
      flash.now[:failure] = updater.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def unapprove
    unapprove_op = Report::Unapprove.new(current_user, params)
    @result = unapprove_op.run
    if unapprove_op.is_success?
      flash.now[:success] = "Report unapproved."
    else
      flash.now[:failure] = unapprove_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def take_control
    take_control_op = Report::TakeControl.new(current_user, params)
    @result = take_control_op.run
    if take_control_op.is_success?
      flash.now[:success] = "You've taken control of this report"
    else
      flash.now[:failure] = take_control_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
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
    @result = reimburse_confirm_op.run
    if reimburse_confirm_op.is_success?
      flash.now[:success] = "Reimbursement confirmed."
    else
      flash.now[:failure] = reimburse_confirm_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

  def comment
    comment_op = Report::Comment::Create.new(current_user, params)
    @result = comment_op.run
    if comment_op.is_success?
      flash.now[:success] = "You've taken control of this report"
    else
      flash.now[:failure] = comment_op.errors
    end
    respond_to do |format|
      format.json do
        render :show
      end
    end
  end

end
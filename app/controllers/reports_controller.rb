class ReportsController < ApplicationController
  include MathUtil
  before_action :authenticate_user!

  def create
    @result = Report::Create.(current_user)
    respond render: :show
  end

  def index
    @result = Report::Index.(current_user, params)
    respond
  end

  def update
    @result = Report::Update.(current_user, params)
    respond render: :show
  end

  def show
    @result = Report::Show.(current_user, params)
    # debugger
    # load_view_for_report
    # @comments = @report.comments.all.order(created_at: :desc)
    # # ap @actions
    respond_to do |format|
      format.json {}
    end
  end

  def destroy
    @result = Report::Destroy.(current_user, params)
    respond response: :success
  end

  def add_expenses
    @result = Report::Expenses::Add.(current_user, params)
    respond render: :show
  end

  def remove_expenses
    @result = Report::Expenses::Remove.(current_user, params)
    respond render: :show
  end

  def submit
    @result = Report::Submit.(current_user, params)
    respond render: :show
  end

  def retract
    @result = Report::Retract.(current_user, params)
    respond render: :show
  end

  def approve
    @result = Report::Approve.(current_user, params)
    respond render: :show
  end

  def reject
    @result = Report::Reject.(current_user, params)
    respond render: :show
  end

  def reject_expense
    @result = Report::Expenses::Reject.(current_user, params)
    respond render: :show
  end

  def unapprove
    @result = Report::Unapprove.(current_user, params)
    respond render: :show
  end

  def take_control
    @result = Report::TakeControl.(current_user, params)
    respond render: :show
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
    @result = Report::ReimburseConfirm.(current_user, params)
    respond render: :show
  end

  def comment
    @result = Report::Comment::Create.(current_user, params)
    respond render: :show
  end

end
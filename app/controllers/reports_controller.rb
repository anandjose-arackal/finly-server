class ReportsController < ApplicationController
  include MathUtil

  before_action -> { finly_authorize! :web}

  def create
    @result = Reports::Create.(current_user, params)
    respond
  end

  def index
    @result = Reports::Index.(current_user, params)
    respond
  end

  def update
    @result = Reports::Update.(current_user, params)
    respond render: :show
  end

  def show
    @result = Reports::Show.(current_user, params)
    respond render: :show
  end

  def report_expenses
    @result = Reports::ReportExpenses.(current_user, params)
    respond
  end

  def report_summary
    @result = Reports::ReportSummary.(current_user, params)
    respond
  end

  def report_comments
    @result = Reports::ReportComments.(current_user, params)
    respond
  end

  def destroy
    @result = Reports::Destroy.(current_user, params)
    respond response: :success
  end

  def add_expenses
    @result = Reports::Expenses::Add.(current_user, params)
    respond render: :show
  end

  def remove_expenses
    @result = Reports::Expenses::Remove.(current_user, params)
    respond render: :show
  end

  def submit
    @result = Reports::Submit.(current_user, params)
    respond render: :show
  end

  def retract
    @result = Reports::Retract.(current_user, params)
    respond render: :show
  end

  def approve
    @result = Reports::Approve.(current_user, params)
    respond render: :show
  end

  def bulk_approve
    @result = Reports::BulkApprove.(current_user, params)
    # respond render: :show
    unless @result.success?
      respond_to do |format|
        format.json {render :bulk_approve_errors }
      end
      # respond render: :bulk_approve_errors
      return
    end
    # respond response: :success
  end

  def reject
    @result = Reports::Reject.(current_user, params)
    respond render: :show
  end

  def reject_expense
    @result = Reports::Expenses::Reject.(current_user, params)
    respond render: :show
  end

  def unapprove
    @result = Reports::Unapprove.(current_user, params)
    respond render: :show
  end

  def take_control
    @result = Reports::TakeControl.(current_user, params)
    respond render: :show
  end

  def toggle_receipt_hardcopy
    @result = Reports::Receipts::ToggleHardCopy.(current_user, params)
    if @result.success?
      render 'toggle_receipt_hardcopy'
    end
    # respond render: :show
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

  def settlement_confirm
    @result = Reports::SettlementConfirm.(current_user, params)
    respond render: :show
  end

  def comment
    @result = Reports::Comment::Create.(current_user, params)
    respond render: :show
  end

  protected
  def respond(item=nil)
    if @result.failure?
      super()
    else
      super(item)
    end
  end

end
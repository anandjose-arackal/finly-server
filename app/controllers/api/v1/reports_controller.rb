# Dir[File.expand_path "app/lib/operations/**/*.rb"].each{|f| require_relative(f)}
require "#{Rails.root}/lib/operations/report/comment/create"
class Api::V1::ReportsController < Api::V1::BaseApiController
  include MathUtil
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def create
    @result = Report::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    end
    respond
  end

  def index
    @result = Report::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def update
    @result = Report::Update.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    end
    respond
  end

  def show
    @result = Report::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def destroy
    @result = Report::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    # if @result.success?
    #   flash.now[:success] = 'Report Deleted'
    #   render 'api/v1/shared/success'
    # end
    respond view: false
  end

  def add_expenses
    @result = Report::Expenses::Add.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def remove_expenses
    @result = Report::Expenses::Remove.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def reject_expense
    @result = Report::Expenses::Reject.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def submit
    @result = Report::Submit.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def retract
    @result = Report::Retract.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def approve
    @result = Report::Approve.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def reject
    @result = Report::Reject.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def unapprove
    @result = Report::Unapprove.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def take_control
    @result = Report::Submit.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def reimbursement_confirm
    @result = Report::ReimburseConfirm.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

  def comment
    @result = Report::Comment::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond
    end
  end

end

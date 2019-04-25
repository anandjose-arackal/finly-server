# Dir[File.expand_path "app/app/operations/**/*.rb"].each{|f| require_relative(f)}
require "#{Rails.root}/app/operations/reports/comment/create"
class Api::V0::ReportsController < Api::V0::BaseApiController
  include MathUtil
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :mobile}


  respond_to :json

  def create
    Formatter.handle_api_nil(params)
    @result = Reports::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    end
    respond
  end

  def index
    @result = Reports::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def update
    Formatter.handle_api_nil(params)
    @result = Reports::Update.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    end
    respond
  end

  def show
    @result = Reports::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def destroy
    @result = Reports::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    # if @result.success?
    #   flash.now[:success] = 'Report Deleted'
    #   render 'api/v0/shared/success'
    # end
    if @result.success?
      render 'api/v0/shared/success'
    else
      render 'api/v0/shared/failure'
    end
  end

  def add_expenses
    @result = Reports::Expenses::Add.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def remove_expenses
    @result = Reports::Expenses::Remove.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def reject_expense
    @result = Reports::Expenses::Reject.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def submit
    @result = Reports::Submit.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def retract
    @result = Reports::Retract.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def approve
    @result = Reports::Approve.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def reject
    @result = Reports::Reject.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def unapprove
    @result = Reports::Unapprove.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def take_control
    @result = Reports::Submit.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def settlement_confirm
    @result = Reports::SettlementConfirm.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

  def comment
    if params[:content].present? and (params[:content] == "" or params[:content] == 'nil')
      params[:content] = nil
    end
    @result = Reports::Comment::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v0/reports/show'
    else
      respond
    end
  end

end

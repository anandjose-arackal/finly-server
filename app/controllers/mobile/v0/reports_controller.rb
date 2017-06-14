# Dir[File.expand_path "app/app/operations/**/*.rb"].each{|f| require_relative(f)}
require "#{Rails.root}/app/operations/report/comment/create"
class Mobile::V0::ReportsController < Mobile::V0::BaseApiController
  include MathUtil
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def create
    Formatter.handle_api_nil(params)
    @result = Report::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    end
    respond
  end

  def index
    @result = Report::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def update
    Formatter.handle_api_nil(params)
    @result = Report::Update.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
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
    #   render 'mobile/v0/shared/success'
    # end
    if @result.success?
      render 'mobile/v0/shared/success'
    else
      render 'mobile/v0/shared/failure'
    end
  end

  def add_expenses
    @result = Report::Expenses::Add.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def remove_expenses
    @result = Report::Expenses::Remove.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def reject_expense
    @result = Report::Expenses::Reject.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def submit
    @result = Report::Submit.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def retract
    @result = Report::Retract.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def approve
    @result = Report::Approve.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def reject
    @result = Report::Reject.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def unapprove
    @result = Report::Unapprove.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def take_control
    @result = Report::Submit.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def settlement_confirm
    @result = Report::SettlementConfirm.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

  def comment
    if params[:content].present? and (params[:content] == "" or params[:content] == 'nil')
      params[:content] = nil
    end
    @result = Report::Comment::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/reports/show'
    else
      respond
    end
  end

end

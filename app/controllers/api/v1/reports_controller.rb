# Dir[File.expand_path "app/app/operations/**/*.rb"].each{|f| require_relative(f)}
require "#{Rails.root}/app/operations/report/comment/create"
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
    else
      respond response: :failure
    end
  end

  def index
    @result = Report::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def update
    action = (params[:action] or :update)
    @result = nil
    case action.to_sym
      when :submit
        @result = Report::Submit.(current_user, params)
      when :retract
        @result = Report::Retract.(current_user, params)
      when :approve
        @result = Report::Approve.(current_user, params)
      when :reject
        @result = Report::Reject.(current_user, params)
      when :unapprove
        @result = Report::Unapprove.(current_user, params)
      when :add_expenses
        @result = Report::Expenses::Add.(current_user, params)
      when :remove_expenses
        @result = Report::Expenses::Remove.(current_user, params)
      when :reimbursement_confirm
        @result = Report::SettlementConfirm.(current_user, params)
      when :reject_expense
        @result = Report::Expenses::Reject.(current_user, params)
      else
        @result = Report::Update.(current_user, params)
    end
    if @result.present?
      @result.config[:mobile_api] = true
      if @result.success?
        respond render: 'api/v1/reports/show'
        return
      end
    end
    respond response: :failure
  end

  def show
    @result = Report::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def destroy
    @result = Report::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  def comment
    if params[:content].present? and (params[:content] == "" or params[:content] == 'nil')
      params[:content] = nil
    end
    @result = Report::Comment::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'api/v1/reports/show'
    else
      respond response: :failure
    end
  end

end

require "#{Rails.root}/app/operations/expense/manual/create"
class Api::V0::ExpensesController < Api::V0::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  def create
    param = RequestFormatter::Api::Mobile::V1::Expenses::Parse.(current_user, params).formatted_request
    @result = Expense::Manual::Create.(current_user, param)
    @result.config[:mobile_api] = true
    if @result.success?
      if @result.expense.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        respond render: 'mobile/v0/reports/show'
      else
        respond render: 'mobile/v0/expenses/show'
      end
    else
      respond
    end
  end

  def index
    @result = Expense::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def show
    @result = Expense::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def update
    param = RequestFormatter::Api::Mobile::V1::Expenses::Parse.(current_user, params).formatted_request
    case params[:type]
      when '1'
        @result = Expense::Manual::Update.(current_user, param)
      when '2'
        @result = Expense::ExCard::Update.(current_user, param)
      else
        respond render: :failure
        return
    end
    @result.config[:mobile_api] = true
    if @result.success?
      if @result.expense.reload.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        respond render: 'mobile/v0/reports/show'
      else
        respond render: 'mobile/v0/expenses/show'
      end
    else
      respond
    end
  end

  def destroy
    @result = Expense::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v0/shared/success'
    else
      respond render: 'mobile/v0/shared/failure'
    end
  end

end

require "#{Rails.root}/app/operations/expense/manual/create"
class Api::V0::ExpensesController < Api::V0::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  def create
    param = RequestFormatter.api_expense(current_user, params)
    @result = Expense::Manual::Create.(current_user, param)
    @result.config[:mobile_api] = true
    if @result.success?
      if @result.expense.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        respond render: 'api/v0/reports/show'
      else
        respond render: 'api/v0/expenses/show'
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
    param = RequestFormatter.api_expense(current_user, params)
    @result = Expense::Manual::Update.(current_user, param)
    @result.config[:mobile_api] = true
    if @result.success?
      if @result.expense.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        respond render: 'api/v0/reports/show'
      else
        respond render: 'api/v0/expenses/show'
      end
    else
      respond
    end
  end

  def destroy
    @result = Expense::Manual::Update.(current_user, params)
    @result.config[:mobile_api] = true
    respond view: false
  end

end

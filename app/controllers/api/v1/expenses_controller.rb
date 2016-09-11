require "#{Rails.root}/lib/operations/expense/manual/create"
class Api::V1::ExpensesController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def create
    param = RequestFormatter.api_expense(current_user, params)
    operation = Expense::Manual::Create.new(current_user, param)
    @result = operation.run
    if operation.is_success?
      if @result.expense.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        render 'api/v1/reports/show'
      else
        render 'api/v1/expenses/show'
      end
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  def index
    operation = Expense::Index.new(current_user, params)
    @result = operation.run
    if operation.is_success?
      render 'api/v1/expenses/index'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  def show
    @result = Expense::Show.(current_user, params)
  end

  def update
    param = RequestFormatter.api_expense(current_user, params)
    operation = Expense::Manual::Update.new(current_user, param)
    @result = operation.run
    if operation.is_success?
      if @result.expense.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        render 'api/v1/reports/show'
      else
        render 'api/v1/expenses/show'
      end
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

  def destroy
    operation = Expense::Manual::Update.new(current_user, params)
    operation.run
    if operation.is_success?
      render 'api/v1/shared/success'
    else
      @errors = operation.errors
      render 'api/v1/shared/failure'
    end
  end

end

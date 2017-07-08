require "#{Rails.root}/app/operations/expense/manual/create"
class Mobile::V1::ExpensesController < Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session

  before_action :doorkeeper_authorize!


  def create
    param = RequestFormatter::ApiParser::MobileParser::V1::Expenses::Parse.(current_user, params).formatted_request

    case params[:type]
      when '1', 1
        @result = Expense::Manual::Create.(current_user, param)
      when '3', 3
        @result = Expense::ExDistance::Create.(current_user, param)
      when '4', 4
        @result = Expense::ExTime::Create.(current_user, param)
      when '5', 5
        @result = Expense::ExPerDiem::Create.(current_user, param)
      else
        respond response: :failure, message: 'Invalid input'
    end

    # @result = Expense::Manual::Create.(current_user, param)
    @result.config[:mobile_api] = true
    if @result.success?
      if @result.expense.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        respond render: 'mobile/v1/reports/show'
      else
        respond render: 'mobile/v1/expenses/show'
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
    param = RequestFormatter::ApiParser::MobileParser::V1::Expenses::Parse.(current_user, params).formatted_request
    case params[:type]
      when '1', 1
        @result = Expense::Manual::Update.(current_user, param)
      when '2', 2
        @result = Expense::ExCard::Update.(current_user, param)
      when '3', 3
        @result = Expense::ExDistance::Update.(current_user, param)
      when '4', 4
        @result = Expense::ExTime::Update.(current_user, param)
      when '5', 5
        @result = Expense::ExPerDiem::Update.(current_user, param)
      else
        respond render: :failure
        return
    end
    @result.config[:mobile_api] = true
    if @result.success?
      if @result.expense.reload.report_id.present?
        @result = Report::Show.(@result.user, report_id: @result.expense.report_id, view: params[:view])
        @result.config[:mobile_api] = true
        respond render: 'mobile/v1/reports/show'
      else
        respond render: 'mobile/v1/expenses/show'
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

  def available_expense_types
    @result = User::AvailableExpenseTypes::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

end

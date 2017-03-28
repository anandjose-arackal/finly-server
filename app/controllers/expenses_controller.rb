class ExpensesController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def create
    case params[:type]
      when '1'
        @result = Expense::Manual::Create.(current_user, params)
      when '3'
        @result = Expense::ExDistance::Create.(current_user, params)
      when '4'
        @result = Expense::ExTime::Create.(current_user, params)
      when '5'
        @result = Expense::ExPerDiem::Create.(current_user, params)
      else
        respond response: :failure, message: "Invalid input"
    end
    respond response: :success
  end

  def show
    @result = Expense::Show.(current_user, params)
    respond
  end

  def index
    @result = Expense::Index.(current_user, params)
    respond
  end

  def update
    case params[:type]
      when '1'
        @result = Expense::Manual::Update.(current_user, params)
      when '2'
        @result = Expense::ExCard::Update.(current_user, params)
      when '3'
        @result = Expense::ExDistance::Update.(current_user, params)
      when '4'
        @result = Expense::ExTime::Update.(current_user, params)
      when '5'
        @result = Expense::ExPerDiem::Update.(current_user, params)
      else
        respond response: :failure, message: "Invalid input"
    end
    respond response: :success
  end

  def destroy
    @result = Expense::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond(response: :failure, message: @result.messages[:error])
    end
  end

  def add_receipt
    @result = Expense::Manual::AddExpense.(current_user, params)
    respond
  end

end
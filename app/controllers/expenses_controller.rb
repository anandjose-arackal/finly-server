class ExpensesController < ApplicationController

  before_action :authenticate_user!

  def create
    @result = Expense::Manual::Create.(current_user, params)
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
      else
        # for testing
        # @result = Expense::Manual::Update.(current_user, params)
        @result = Expense::ExCard::Update.(current_user, params)
    end
    respond response: :success
  end

  def destroy
    @result = Expense::Manual::Destroy.(current_user, params)
    respond response: :success
  end

  def add_receipt
    @result = Expense::Manual::AddExpense.(current_user, params)
    respond
  end

end
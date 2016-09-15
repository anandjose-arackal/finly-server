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
    @result = Expense::Manual::Update.(current_user, params)
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
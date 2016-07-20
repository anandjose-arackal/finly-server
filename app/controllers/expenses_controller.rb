class ExpensesController < ApplicationController

  before_action :authenticate_user!
  before_action :retrieve_service_objects

  def new

  end

  def index
    # returns the expenses of the user
    @expenses = @expense_service.list_expenses.paginate(page: params[:page])
  end

  def create
    if @expense_service.add_expense expense_params
      flash[:success] = "Expense created!"
    else
      flash[:danger] = "Error. Please try again"
    end
    redirect_to expenses_path
  end

  def attach_receipt

  end

  def detach_receipt

  end

  def destroy

  end

  private

  def expense_params
    ###### todo temporary - will be removed after currency is added in main screen###
    params[:expense][:currency_id] = 1
    ##########################################################################

    params[:expense][:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    params[:expense][:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
    params.permit!

  end

  def retrieve_service_objects
    @expense_service = ExpenseService.new(current_user)
  end

end

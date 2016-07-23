class ExpensesController < ApplicationController

  before_action :authenticate_user!
  before_action :retrieve_service_objects

  # scopes for filters
  has_scope :filter_category_id
  has_scope :filter_merchant
  # has_scope :filter_receipt
  has_scope :filter_search
  has_scope :filter_amount, using: [:type, :value], type: :hash
  has_scope :filter_status_id
  has_scope :filter_date, using: [:from, :to], type: :hash

  def new

  end

  def index
    # currently returns only the personal expenses of the user
    @expenses = apply_scopes(@expense_service.list_expenses).paginate(page: params[:page])
    # for the filters
    @merchants = []
    @expense_service.list_expenses.each do |expense|
      @merchants << expense.merchant_name
    end
    @categories = current_company.active_categories
  end

  def create
    if @expense_service.add_expense expense_params
      flash[:success] = "Expense created!"
    else
      flash[:danger] = "Error. Please try again"
    end
    redirect_to expenses_path
  end

  def update
    if @expense_service.update_expense(current_user, expense_params)
      flash[:success] = "Expense edited!"
    else
      flash[:danger] = "Error. Please try again"
    end
    redirect_to expenses_path
  end

  def destroy
    if @expense_service.remove_expense(params[:id] || params[:expense_id])
      flash[:success] = "Expense deleted!"
    else
      flash[:danger] = "Error. Please try again"
    end
    redirect_to expenses_path
  end

  def add_receipt
    if @expense_service.add_receipt_to_expense(expense_params, params[:id] || params[:expense_id])
      flash[:success] = "receipt added!"
    else
      flash[:danger] = "Error. Please try again"
    end
    redirect_to expenses_path
  end

  def attach_receipt

  end

  def detach_receipt

  end


  private

  def expense_params
    ###### todo temporary - will be removed after currency is added in main screen###
    params[:expense][:currency_id] = Currency.first.id
    ##########################################################################

    params[:expense][:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    params[:expense][:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
    params.permit!

  end

  def retrieve_service_objects
    @expense_service = ExpenseService.new(current_user)
  end

end

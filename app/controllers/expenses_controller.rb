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
    role = UserRole.employee_id
    if @admin_view
      role = UserRole.admin_id
    elsif @finance_view
      role = UserRole.finance_manager_id
    elsif @manager_view
      role = UserRole.manager_id
    end
    @expenses = @expense_service.expenses(role)
    # for the filters
    if @expenses.present?
      @count = @expenses.count
      @merchants = @expenses.include_manual_expense.pluck(:merchant)
      @expenses = apply_scopes(@expense_service.expenses(role)).paginate(page: params[:page], per_page: 30)
    end
    @categories = current_company.active_categories
    generate_filters
  end

  def create
    if @expense_service.add_expense expense_params
      flash.now[:success] = 'Expense created!'
      if params['request_type'] == '1'
        redirect_to expenses_path
      else
        redirect_to request.referrer
      end
    else
      flash.now[:danger] = @expense_service.errors
      render_flash_message
    end

  end

  def update
    if @expense_service.update_expense(current_user, expense_params)
      flash[:success] = 'Expense edited!'
      redirect_to expenses_path
    else
      flash[:danger] = @expense_service.errors
      render_flash_message
    end
  end

  def destroy
    if @expense_service.remove_expense(params[:id] || params[:expense_id])
      flash[:success] = "Expense deleted!"
    else
      flash[:danger] = @expense_service.errors
    end
    redirect_to request.referrer
  end

  def add_receipt
    if @expense_service.add_receipt_to_expense(expense_params, params[:id] || params[:expense_id])
      flash[:success] = "receipt added!"
    else
      flash[:danger] = @expense_service.errors
    end
    redirect_to request.referrer
  end

  def attach_receipt

  end

  def detach_receipt

  end

  def unreported
    @unreported_expenses = apply_scopes(current_user.expenses.unreported)
    respond_to do |format|
      format.js
    end
  end


  private
  def generate_filters
    @filter = {}
    if params[:filter_status].present?
      status_id = params[:filter_status]
      status = ExpenseStatus.find_by(id: status_id)
      @filter[:status] = status.name if status.present?
    end
    if params[:filter_category_id].present?
      category_id = params[:filter_category_id]
      category = current_company.categories.find_by(id: category_id)
      @filter[:category] = category.name if category.present?
    end
    # todo filters for manager and user for admin views expenses
  end

  def expense_params
    ###### todo temporary - will be removed after currency is added in main screen###
    params[:expense][:currency_id] = Currency.first.id
    ##########################################################################

    params[:expense][:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    params[:expense][:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
    params[:expense][:receipts_attributes] = [{image: params[:expense][:receipt], user_id: current_user.id}] if params[:expense][:receipt]
    params.permit!

  end

  def retrieve_service_objects
    @expense_service = ExpenseService.new(current_user)
  end

end

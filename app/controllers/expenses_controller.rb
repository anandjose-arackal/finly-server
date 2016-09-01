class ExpensesController < ApplicationController

  before_action :authenticate_user!
  before_action :retrieve_service_objects
  before_action :load_expense, only: [:update, :destroy, :add_receipt]

  # # scopes for filters
  # has_scope :filter_sort, using: [:sort_by, :order], type: :hash
  # has_scope :filter_category_id
  # has_scope :filter_merchant
  # has_scope :filter_receipt
  # has_scope :filter_search
  # has_scope :filter_amount, using: [:type, :value], type: :hash
  # has_scope :filter_status_id
  # has_scope :filter_date, using: [:from, :to], type: :hash

  def new

  end

  def show
    @expense = current_user.expenses.find_by(id: params[:id] || params[:expense_id])
    respond_to do |format|
      # format.html {}
      # format.json { render json: @expenses.as_json }
      format.json {}
    end 
  end

  def create
    create_op = Expense::Manual::Create.new(current_user, params)
    if create_op.run
      respond_to do |format|
        format.json { render json: {"status": "success"} }
      end
    else
      flash.now[:danger] = create_op.errors
      render_flash_message
    end
  end

  def index
    role = UserRole.employee_id
    if @admin_view
      role = UserRole.admin_id
    elsif @finance_view
      role = UserRole.finance_manager_id
    elsif @manager_view
      role = UserRole.manager_id
    end
    @expense_presenter = Expense::Index.new(current_user, role, params).run
    @expenses = @expense_presenter.expenses
    # for the filters
    if @expenses.present?
      @expenses = @expenses.paginate(page: params[:page], per_page: 15)
    end
    # generate_filters

    respond_to do |format|
      format.html {}
      # format.json { render json: @expenses.as_json }
      format.json {}
    end
  end

  def update
    update_op = Expense::Manual::Update.new(current_user, params)
    if update_op.run
      # flash[:success] = 'Expense edited!'
      # redirect_to request.referrer
      respond_to do |format|
        format.json { render json: {"status": "success"} }
      end
    else
      flash[:danger] = update_op.errors
      render_flash_message
    end
  end

  def destroy
    destroy_op = Expense::Manual::Destroy.new(current_user, params)
    if destroy_op.run
      flash[:success] = "Expense deleted!"
    else
      flash[:danger] = @expense_service.errors
    end
    # redirect_to request.referrer
    respond_to do |format|
      format.json {render json: {"status": "success"}}
    end
  end

  def add_receipt
    add_receipt_op = Expense::Manual::AddExpense.new(current_user, params).run
    if add_receipt_op.run
      flash[:success] = "receipt added!"
    else
      flash[:danger] = add_receipt_op.errors
    end
    redirect_to request.referrer
  end


  def unreported
    authorize Expense
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
    #################################################################################

    params[:expense][:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    params[:expense][:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
    params[:expense][:receipts_attributes] = [{image: params[:expense][:receipt], user_id: current_user.id}] if params[:expense][:receipt].present?
    params.require(:expense).permit(:currency_id, :expense_type_id, :expense_status_id, :note, :receipt, :receipt_id, :report_id, :category_id, :date,
                                    amount_attributes: [:value, :currency_id], manual_expense_attributes: [:merchant], receipts_attributes: [:image, :user_id, :id])
  end

  def receipt_params
    params.require(:receipt).permit(:image)
  end

  def retrieve_service_objects
    @expense_service = ExpenseService.new(current_user)
  end

  def load_expense
    @expense = current_user.expenses.find_by(id: params[:expense_id] || params[:id])
  end

end

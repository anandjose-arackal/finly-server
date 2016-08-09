class Api::V1::ExpensesController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!
  before_action :retrieve_service_objects
  before_action :load_expense, only: [:show, :update, :destroy, :add_receipt]
  before_action :load_receipt, only: [:create, :add_receipt, :update]

  respond_to :json

  # scopes for filters
  has_scope :filter_category_id
  has_scope :filter_merchant
  # has_scope :filter_receipt
  has_scope :filter_search
  has_scope :filter_amount, using: [:type, :value], type: :hash
  has_scope :filter_status_id
  has_scope :filter_date, using: [:from, :to], type: :hash

  def create
    authorize Expense
    if @expense_service.add_expense expense_params
      render 'api/v1/shared/success'
    else
      @errors = @expense_service.errors
      render 'api/v1/shared/failure'
    end
  end

  def index
    authorize Expense
    # currently returns only the personal expenses of the user
    role = UserRole.employee_id
    if @admin_view
      role = UserRole.admin_id
    elsif @finance_view
      role = UserRole.finance_manager_id
    elsif @manager_view
      role = UserRole.manager_id
    end
    @expenses = apply_scopes(@expense_service.expenses(role)).paginate(page: params[:page], per_page: 30)
  end

  def show
    authorize @expense
  end

  def update
    authorize @expense
    if @expense_service.update_expense(current_user, expense_params)
      render 'api/v1/expenses/show'
    else
      @errors = @expense_service.errors
      render 'api/v1/shared/failure'
    end
  end

  def destroy
    authorize @expense
    id = (params[:id] or params[:expense_id])
    if @expense_service.remove_expense(id)
      render 'api/v1/shared/success'
    else
      @errors = @expense_service.errors
      render 'api/v1/shared/failure'
    end
  end

  def add_receipt
    authorize @expense
    id = (params[:id] or params[:expense_id])
    if @expense_service.add_receipt_to_expense(receipt_params, id)
      render 'api/v1/expenses/show'
    else
      @errors = @expense_service.errors
      render 'api/v1/shared/failure'
    end
  end

  private
  def expense_params
    ###### todo temporary - will be removed after currency is added in main screen###
    params[:currency_id] = Currency.first.id
    ##########################################################################
    params[:amount_attributes] = {value: params[:amount], currency_id: params[:currency_id]}
    params[:manual_expense_attributes] = {merchant: params[:merchant]}
    params[:receipts_attributes] = [{image: params[:receipt], user_id: current_user.id}] if params[:receipt]
    params.require(:expense).permit(:currency_id, :expense_type_id, :expense_status_id, :receipt, :receipt_id, :report_id, :category_id, :date,
                                    amount_attributes: [:value, :currency_id], manual_expense_attributes: [:merchant], receipts_attributes: [:image, :user_id])
  end

  def receipt_params
    params.require(:receipt).permit(:image)
  end

  def retrieve_service_objects
    @expense_service = ExpenseService.new(current_user)
  end

  def load_expense
    id = (params[:expense_id] or params[:id])
    @expense = current_user.expenses.find_by(id: id)
  end

  def load_receipt
    if params[:receipt] and params[:receipt] != 'nil'
      params[:expense] = {} if params[:expense].blank?
      params[:expense][:receipt] = extract_receipt_image
    end
  end

  def extract_receipt_image
    data = params[:receipt]
    file = data.tempfile
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = params[:filename]
    file.content_type = params[:content_type]
    file
  end

end

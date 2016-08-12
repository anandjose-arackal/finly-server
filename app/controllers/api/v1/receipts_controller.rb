class Api::V1::ReceiptsController < Api::V1::BaseApiController


  before_action :authenticate_user!
  before_action :pundit_permission
  before_action :parse_receipt, only: [:create]

  def create
    receipt_service = ReceiptService.new(current_user)
    if receipt_service.create_receipt(receipt_params)
      render 'api/v1/shared/success'
    else
      @errors = receipt_service.errors
      render 'api/v1/shared/failure'
    end
  end

  def index
    load_receipts
  end

  def destroy
    receipt_service = ReceiptService.new current_user
    if receipt_service.destroy_receipt(params[:id])
      render 'api/v1/shared/success'
    else
      @errors = receipt_service.errors
      render 'api/v1/shared/failure'
    end
  end

  def expense_from_receipt
    expense_service = ExpenseService.new(current_user)
    receipt_id = expense_params[:expense][:receipt_id]
    if expense_service.expense_from_receipt(expense_params, receipt_id)
      render 'api/v1/shared/success'
    else
      @errors = receipt_service.errors
      render 'api/v1/shared/failure'
    end
  end

  def add_note
    @receipt = current_user.receipts.find_by(id: params[:receipt_id])
    note = receipt_params[:note]
    if @receipt.update_attributes(note: note)
      render 'api/v1/shared/success'
    else
      @errors = receipt_service.errors
      render 'api/v1/shared/failure'
    end
  end

  private

  def expense_params
    ###### todo temporary - will be removed after currency is added in main screen###
    params[:expense][:currency_id] = Currency.first.id
    ##########################################################################

    params[:expense][:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    params[:expense][:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
    params[:expense][:receipts_attributes] = [{image: params[:expense][:receipt], user_id: current_user.id}] if params[:expense][:receipt]
    params.require(:expense).permit(:currency_id, :expense_type_id, :expense_status_id, :receipt, :receipt_id, :report_id, :category_id, :date,
                                    amount_attributes: [:value, :currency_id], manual_expense_attributes: [:merchant], receipts_attributes: [:image, :user_id])

  end

  def receipt_params
    params.require(:receipt).permit(:image)
  end

  def load_receipts
    @receipts = current_user.receipts.without_parent
  end

  def pundit_permission
    authorize Receipt
  end

  def parse_receipt
    params[:image] = {}
    params[:receipt][:image] = extract_receipt_image
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

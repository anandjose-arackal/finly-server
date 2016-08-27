class ReceiptsController < ApplicationController

  before_action :authenticate_user!
  before_action :pundit_permission

  def index
    load_receipts
  end

  def create
    receipt_service = ReceiptService.new(current_user)
    if receipt_service.create_receipt(receipt_params)
      flash.now[:success] = "Receipt added!"
      respond_to do |format|
        format.html { redirect_to (request.referrer or receipts_path) }
        format.js do
          load_receipts
          render 'receipts/index_update'
        end
      end
    else
      flash.now[:danger] = receipt_service.errors
      render_flash_message
    end
  end

  def destroy
    receipt_service = ReceiptService.new current_user
    if receipt_service.destroy_receipt(params[:id])
      flash.now[:success] = "Receipt destroyed!"
      respond_to do |format|
        format.html { redirect_to (request.referrer or receipts_path) }
        format.js do
          load_receipts
          render 'receipts/index_update'
        end
      end
    else
      flash.now[:danger] = receipt_service.errors
      render_flash_message
    end
  end

  def expense_from_receipt
    expense_service = ExpenseService.new(current_user)
    receipt_id = expense_params[:receipt_id]
    if expense_service.expense_from_receipt(expense_params, receipt_id)
      flash.now[:success] = "Expense created!"
      respond_to do |format|
        format.html { redirect_to (request.referrer or receipts_path) }
        format.js do
          load_receipts
          render 'receipts/index_update'
        end
      end
    else
      flash.now[:danger] = expense_service.errors
      render_flash_message
    end
  end

  def add_note
    @receipt = current_user.receipts.find_by(id: params[:receipt_id])
    note = receipt_params[:note]
    if @receipt.update_attributes(note: note)
      flash.now[:success] = "Note added"
      render_flash_message
    else
      flash[:danger] = "Error try again."
      render_flash_message
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
    params.require(:expense).permit(:currency_id, :expense_type_id, :expense_status_id, :receipt, :receipt_id, :report_id, :category_id, :date, :note,
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

end

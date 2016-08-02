class ReceiptsController < ApplicationController

  before_action :authenticate_user!

  def index
    @receipts = current_user.receipts.without_parent
  end

  def create
    receipt_service = ReceiptService.new(current_user)
    if receipt_service.create_receipt(receipt_params)
      flash[:success] = "Receipt added!"
      redirect_to (request.referrer or receipts_path)
    else
      flash.now[:danger] = receipt_service.errors
      render_flash_message
    end
  end

  def destroy
    receipt_service = ReceiptService.new(current_user)
    if receipt_service.destroy_receipt(receipt_params[:receipt_id])
      flash[:success] = "Receipt added!"
      redirect_to (request.referrer or receipts_path)
    else
      flash.now[:danger] = receipt_service.errors
      render_flash_message
    end
  end

  def expense_from_receipt
    expense_service = ExpenseService.new(current_user)
    receipt_id = expense_params[:expense][:receipt_id]
    if expense_service.expense_from_receipt(expense_params, receipt_id)
      flash[:success] = "Expense created!"
      redirect_to (request.referrer or receipts_path)
    else
      flash.now[:danger] = expense_service.errors
      render_flash_message
    end
  end

  def add_note
    @receipt = current_user.receipts.find_by(id: params[:receipt_id])
    note = receipt_params[:note]
    if @receipt.update_attributes(note: note)
      flash[:success] = "Note added"
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
    params.permit!

  end

  def receipt_params
    params.require(:receipt).permit!
  end

end

class ReceiptsController < ApplicationController

  before_action :authenticate_user!
  before_action :retrieve_service_objects

  def index
    @receipts = current_user.receipts.without_parent
  end

  def create
    if @receipt_service.create_receipt(receipt_params)
      flash[:success] = "Receipt added!"
    else
      flash[:danger] = @receipt_service.errors
    end
    redirect_to request.referrer
  end

  def destroy
    if @receipt_service.destroy_receipt(receipt_params[:receipt_id])
      flash[:success] = "Receipt added!"
    else
      flash[:danger] = @receipt_service.errors
    end
    redirect_to request.referrer
  end

  def expense_from_receipt
    receipt_id = expense_params[:expense][:receipt_id]
    if @expense_service.expense_from_receipt(expense_params, receipt_id)
      flash[:success] = "Expense created!"
    else
      flash[:danger] = @expense_service.errors
    end
    redirect_to request.referrer
  end

  def add_note
    @receipt = current_user.receipts.find_by(id: params[:receipt_id])
    note = receipt_params[:note]
    if @receipt.update_attributes(note: note)
      flash[:success] = "Note added"
      render partial: 'shared/flash_message', replace: "#flashContainer"
    else
      flash[:danger] = "Error try again."
      render partial: 'shared/flash_message', replace: "#flashContainer"
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

  def retrieve_service_objects
    @receipt_service = ReceiptService.new(current_user)
    @expense_service = ExpenseService.new(current_user)
  end
end

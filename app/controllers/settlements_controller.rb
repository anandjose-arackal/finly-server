class SettlementsController < ApplicationController
  before_action :authenticate_user!
  allow_oauth!

  def create
    success_message = nil
    operation = nil
    if params[:payment_type] == PaymentType.id_for(:add_cash_on_hand).to_s
      operation = Settlement::Payment::AddCashAdvance.new(current_user, params)
    elsif params[:payment_type] == PaymentType.id_for(:deduct_cash_on_hand).to_s
      operation = Settlement::Payment::AddDebtToCompanyClearance.new(current_user, params)
    elsif params[:payment_type] == PaymentType.id_for(:reimbursement).to_s
      operation = Settlement::Payment::AddSettlement.new(current_user, params)
    end
    if operation.blank?
      respond_failure 'Error while creating payment. Unknown type'
      return
    end
    @result = operation.run
    debugger
    respond(response: :success, message: success_message)
  end

  def index
    @result = Settlement::Index.(current_user, params)
    respond
  end

  def show
    @result = Settlement::Show.(current_user, params)
    respond
  end

  def summary
    @result = Settlement::Summary.(current_user, params)
    respond
  end

end

class SettlementsController < ApplicationController
  before_action :authenticate_user!

  def create
    success_message = nil
    operation = nil
    if params[:payment_type] == PaymentType.advance_id.to_s
      operation = Settlement::Payment::AddCashAdvance.new(current_user, params)
      success_message = 'Cash advance added'
    elsif params[:payment_type] == PaymentType.debt_clearance_id.to_s
      operation = Settlement::Payment::AddDebtToCompanyClearance.new(current_user, params)
      success_message = 'debt clearance payment added'
    elsif params[:payment_type] == PaymentType.reimbursement_id.to_s
      operation = Settlement::Payment::AddReimbursement.new(current_user, params)
      success_message = 'Reimbursement added'
    elsif params[:payment_type] == PaymentType.settlement_id.to_s
      operation = Settlement::Payment::Settle.new(current_user, params)
      success_message = 'Payment settled'
    end
    if operation.blank?
      respond_failure 'Error while creating payment. Unknown type'
      return
    end
    @result = operation.run
    respond(response: :success, message: success_message)
  end

  def index
    operation = Settlement::Index.new(current_user, params)
    @result = operation.run
    respond
  end

  def show
    # @view_to_load = params[:view_to_load] unless params[:view_to_load] == 'payments' else
    @result = Settlement::Show.(current_user, params)
    respond
  end

  def summary
    # ap params
    operation = Settlement::Show.new(current_user, params)
    @result = operation.run
    respond
  end

end

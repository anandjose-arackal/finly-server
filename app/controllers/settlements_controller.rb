class SettlementsController < ApplicationController
  before_action :authenticate_user!

  def create
    success_message = nil
    operation = nil
    if params[:payment_type] == PaymentType.id_for(:advance).to_s
      operation = Settlement::Payment::AddCashAdvance.new(current_user, params)
    elsif params[:payment_type] == PaymentType.id_for(:debt_clearance).to_s
      operation = Settlement::Payment::AddDebtToCompanyClearance.new(current_user, params)
    elsif params[:payment_type] == PaymentType.id_for(:reimbursement).to_s
      operation = Settlement::Payment::AddReimbursement.new(current_user, params)
    elsif params[:payment_type] == PaymentType.id_for(:settlement).to_s
      operation = Settlement::Payment::Settle.new(current_user, params)
    end
    if operation.blank?
      respond_failure 'Error while creating payment. Unknown type'
      return
    end
    @result = operation.run
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
    @result = Settlement::Show.(current_user, params)
    respond
  end

end

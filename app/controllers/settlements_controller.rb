class SettlementsController < ApplicationController
  before_action :authenticate_user!

  def create
    success_message = nil
    operation = nil
    debugger
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
      flash.now[:failure] = 'Unknown error'
      # todo render
      return
    end
    @result = operation.run
    if operation.is_success?
      flash.now[:success] = 'payment successfully added'
      flash.now[:success] = success_message if success_message.present?
      # todo render
    else
      flash.now[:danger] = operation.errors
      # todo render
    end
  end

  def index
    operation = Settlement::Index.new(current_user, params)
    @result = operation.run
    # authorize Payment
    # @users = @users.with_roles.only_employees.paginate(page: params[:page], per_page: 30) if @users.present?
    # ap @users
    respond_to do |format|
      format.html {}
      format.js {}
      format.json { render json: @result.users.as_json }
    end
  end

  def show
    # Settlement::Show.new(Userviewing, {view_to_load: 'payments', view: 'admin', id: Usertoshow.id})
    if params[:view_to_load] == 'payments'
      @view_to_load = params[:view_to_load]
    else
      @view_to_load = 'reports'
    end

    # @view_to_load = params[:view_to_load] unless params[:view_to_load] == 'payments' else 
    operation = Settlement::Show.new(current_user, params)
    @result = operation.run
    # ap @result
    # todo render
    respond_to do |format|
      format.json {}
    end
  end

  def summary
    operation = User::Show.new(current_user, params)
    @result = operation.run
    ap @result
    respond_to do |format|
      format.json {}
    end
  end

end

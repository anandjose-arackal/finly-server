class SettlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:show]

  def create
    params[:to_user_id] = @user
    success_message = nil
    operation = nil
    if param[:payment_type] == PaymentType.advance_id.to_s
      operation = Settlement::Payment::AddCashAdvance.new(current_user, params)
      success_message = 'Cash advance added'
    elsif param[:payment_type] == PaymentType.debt_clearance_id.to_s
      operation = Settlement::Payment::AddDebtToCompanyClearance.new(current_user, params)
      success_message = 'debt clearance payment added'
    elsif param[:payment_type] == PaymentType.reimbursement_id.to_s
      operation = Settlement::Payment::AddReimbursement.new(current_user, params)
      success_message = 'Reimbursement added'
    elsif param[:payment_type] == PaymentType.settlement_id.to_s
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
    operation = Settlement::Index.new(user, params)
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
    operation = Settlement::Show.new(user, params)
    @result = operation.run
    # todo render
  end

  def summary
    operation = User::Show.new(user, params)
    @result = operation.run
    respond_to do |format|
      format.json {}
    end
  end

end

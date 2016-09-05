class ExpensesController < ApplicationController

  before_action :authenticate_user!

  def show
    operation = Expense::Show.new(current_user, params)
    @result = operation.run

    respond_to do |format|
      # format.html {}
      # format.json { render json: @expenses.as_json }
      format.json {}
    end
  end

  def create
    # debugger
    create_op = Expense::Manual::Create.new(current_user, params)
    if create_op.run
      respond_to do |format|
        format.json { render json: {"status": "success"} }
      end
    else
      flash.now[:danger] = create_op.errors
      render_flash_message
    end
  end

  def index
    operation = Expense::Index.new(current_user, params)
    @result = operation.run

    respond_to do |format|
      format.html {}
      format.json {}
    end
  end

  def update
    update_op = Expense::Manual::Update.new(current_user, params)
    if update_op.run
      respond_to do |format|
        format.json { render json: {"status": "success"} }
      end
    else
      flash[:danger] = update_op.errors
      render_flash_message
    end
  end

  def destroy
    destroy_op = Expense::Manual::Destroy.new(current_user, params)
    if destroy_op.run
      flash[:success] = "Expense deleted!"
    else
      flash[:danger] = @expense_service.errors
    end
    respond_to do |format|
      format.json {render json: {"status": "success"}}
    end
  end

  def add_receipt
    add_receipt_op = Expense::Manual::AddExpense.new(current_user, params).run
    if add_receipt_op.run
      flash[:success] = "receipt added!"
    else
      flash[:danger] = add_receipt_op.errors
    end
    redirect_to request.referrer
  end

end

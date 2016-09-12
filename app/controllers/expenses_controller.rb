class ExpensesController < ApplicationController

  before_action :authenticate_user!

  def show
    operation = Expense::Show.new(current_user, params)
    @result = operation.run
    respond
  end

  def create
    # debugger
    create_op = Expense::Manual::Create.new(current_user, params)
    @result = create_op.run
    respond response: :success
  end

  def index
    operation = Expense::Index.new(current_user, params)
    @result = operation.run
    respond
  end

  def update
    update_op = Expense::Manual::Update.new(current_user, params)
    @result = update_op.run
    respond response: :success
  end

  def destroy
    destroy_op = Expense::Manual::Destroy.new(current_user, params)
    @result = destroy_op.run
    respond response: :success
  end

  def add_receipt
    add_receipt_op = Expense::Manual::AddExpense.new(current_user, params).run
    @result = add_receipt_op.run
    respond
  end

end

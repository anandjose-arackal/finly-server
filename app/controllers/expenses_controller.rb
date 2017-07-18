class ExpensesController < ApplicationController

  before_action -> { doorkeeper_authorize! :web}

  def create
    case params[:type]
      when '1'
        @result = Expense::Manual::Create.(current_user, params)
      when '3'
        @result = Expense::ExDistance::Create.(current_user, params)
      when '4'
        @result = Expense::ExTime::Create.(current_user, params)
      when '5'
        @result = Expense::ExPerDiem::Create.(current_user, params)
      when '6'
        @result = Expense::Manual::Multiple::Create.(current_user, params)
        unless @result.success?
          respond render: "multiple_errors"
          return
        end
      when '7'
        @result = Expense::ExDistance::Multiple::Create.(current_user, params)
        unless @result.success?
          respond render: "multiple_errors"
          return
        end
      when '8'
        @result = Expense::ExTime::Multiple::Create.(current_user, params)
        unless @result.success?
          respond render: "multiple_errors"
          return
        end
      when '9'
        @result = Expense::ExPerDiem::Multiple::Create.(current_user, params)
        unless @result.success?
          respond render: "multiple_errors"
          return
        end
      else
        respond response: :failure, message: "Invalid input"
    end
    respond response: :success
  end

  def show
    @result = Expense::Show.(current_user, params)
    respond
  end

  def index
    @result = Expense::Index.(current_user, params)
    respond
  end

  def update
    case params[:type]
      when '1'
        @result = Expense::Manual::Update.(current_user, params)
      when '2'
        @result = Expense::ExCard::Update.(current_user, params)
      when '3'
        @result = Expense::ExDistance::Update.(current_user, params)
      when '4'
        @result = Expense::ExTime::Update.(current_user, params)
      when '5'
        @result = Expense::ExPerDiem::Update.(current_user, params)
      else
        respond response: :failure, message: "Invalid input"
    end
    respond response: :success
  end

  def update_status

  end

  def destroy
    @result = Expense::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond(response: :failure, message: @result.messages[:error])
    end
  end

  def add_receipt
    @result = Expense::Manual::AddExpense.(current_user, params)
    respond
  end

  def mark
    case params[:type]
      when 1, '1'
        # insert logic for expense cancellation
        @result = Expense::Cancelled::Mark.(current_user, params)
      when 2, '2'
        # insert logic for marking expense as personal
        @result = Expense::Personal::Mark.(current_user, params)
      when 3, '3'
        # insert logic for marking expense as non-reimbursable - because by defualt all expenses are reimbursable
        @result = Expense::Reimbursable::Mark.(current_user, params)
      else
        @result = Expense::Reimbursable::Mark.(current_user, params)
    end
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def unmark
    case params[:type]
      when 1, '1'
        # insert logic for expense cancellation
        @result = Expense::Cancelled::Unmark.(current_user, params)
      when 2, '2'
        # insert logic for marking expense as personal
        @result = Expense::Personal::Unmark.(current_user, params)
      when 3, '3'
        # insert logic for marking expense as non-reimbursable - because by defualt all expenses are reimbursable
        @result = Expense::Reimbursable::Unmark.(current_user, params)
      else
        @result = Expense::Reimbursable::Unmark.(current_user, params)
    end
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def duplicates
    @result = Expense::Manual::Duplicate::Show.(current_user, params)
    respond
  end

end
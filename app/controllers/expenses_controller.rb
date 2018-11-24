class ExpensesController < ApplicationController

  before_action -> { finly_authorize! :web }

  def create
    case params[:type]
      when '1'
        if params[:split]
          @result = Expense::Manual::Split.(current_user, params)
        else
          @result = Expense::Manual::Create.(current_user, params)
        end
      when '3'
        case params[:distance_type]
          when 1, '1', nil
            @result = Expense::ExDistance::Create.(current_user, params)
          when 2,'2'
            @result = Expense::ExDistance::Odometer::ExCreate.(current_user, params)
        end
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
        return
    end

    if current_user.company.id == 129 || current_user.company.id == 1
      if @result.success?
        params[:id] = @result.expense&.id
        messages = @result.messages
        @result = Expense::Show.(current_user, params)

        @result.messages = messages
        respond render: 'show'
      else
        respond response: :success
      end
    else
      respond response: :success
    end
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
        case params[:distance_type]
          when 1, '1', nil
            @result = Expense::ExDistance::Update.(current_user, params)
          when 2,'2'
            @result = Expense::ExDistance::Odometer::ExUpdate.(current_user, params)
        end
      when '4'
        @result = Expense::ExTime::Update.(current_user, params)
      when '5'
        @result = Expense::ExPerDiem::Update.(current_user, params)
      else
        # respond response: :failure, message: "Invalid input"
    end
    respond(response: (@result&.success? ? :success : :failure), message: (@result&.success? ? @result.messages[:success] : "Invalid Input"))
  end

  def split_existing
    @result = Expense::SplitExisting.(current_user, params)
    if @result&.success?
      respond(response: (@result&.success? ? :success : :failure), message: (@result&.success? ? @result.messages[:success] : @result.messages[:error]))
    else
      respond response: :failure, message: @result&.messages[:error]
    end
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

  def export
    @result = Export::Expense::AsSpreadsheet.(current_user, params)
    respond
  end

  def expense_edit_config
    @result = Expense::ExpenseEditConfig.(current_user, params)
    respond
  end

  def currencies
    @result = User::AvailableExpenseTypes::Show.(current_user, params)
    respond
  end

end

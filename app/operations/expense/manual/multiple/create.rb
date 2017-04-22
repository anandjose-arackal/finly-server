class Expense::Manual::Multiple::Create < Expense::Manual::Multiple::Base

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end

    if params.blank?
      add_message :error, "No parameters found."
    end

    if params[:multiple].blank?
      add_message :error, "Create at least one expense to proceed."
    end
  end

  def init
  end

  def validate
    @valid = true
    expenses = params[:multiple]

    @multiple_errors = {}
    for key, value  in expenses #value is params for Validate Class
      # debugger
      expense = Expense::Manual::Validate.(user, value)

      @multiple_errors[key] = expense.messages
      # debugger
      unless @multiple_errors[key][:error].blank? && @multiple_errors[key][:failure].blank?
        @valid = false
      end
    end
  end

  def process
    if @valid
      expenses = params[:multiple]
      for key, value in expenses
        expense = Expense::Manual::Create.(user, value)
      end
      add_message :success, "Created #{expenses.values.length} expenses successfully."
    else
      add_message :failure, 'Cannot create expenses. Please fix the errors and try again.' 
    end
  end

  def post_process

  end


  def failure
    params[:multiple_errors] = @multiple_errors
    Expense::Manual::Multiple::Base::FailurePresenter.new(user, params, messages)
  end

  class Expense::Manual::Multiple::Base::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :multiple_errors

    def init
      @multiple_errors = params[:multiple_errors]
    end

    def formatted_messages
      @multiple_errors
    end
  end
end
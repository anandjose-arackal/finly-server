class Expense::Manual::Multiple::Create < Expense::Manual::Multiple::Base
  attr_accessor :valid, :errors_by_expenses

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
    self.valid = true
    expenses = params[:multiple]

    self.errors_by_expenses = {}
    for key, params_each_expense  in expenses #value is params for Validate Class
      expense = Expense::Manual::Validate.(user, params_each_expense)

      self.errors_by_expenses[key] = expense.messages
      unless self.errors_by_expenses[key][:error].blank? && self.errors_by_expenses[key][:failure].blank?
        self.valid = false
      end
    end
  end

  def process
    # debugger
    if self.valid

      expenses = params[:multiple]
      for key, value in expenses
        expense = Expense::Manual::Create.(user, value)
        # debugger
      end
      add_message :success, "Created #{expenses.values.length} expenses successfully."
    else
      add_message :failure, 'Cannot create expenses. Please fix the errors and try again.' 
    end
  end

  def post_process

  end


  def failure
    params[:expense_errors] = self.errors_by_expenses
    Expense::Manual::Multiple::Base::FailurePresenter.new(user, params, messages)
  end

  class Expense::Manual::Multiple::Base::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :expense_errors
    def init
      self.expense_errors = params[:expense_errors]
    end

    def formatted_messages
      self.expense_errors
    end
  end
end
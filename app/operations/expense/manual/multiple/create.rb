class Expense::Manual::Multiple::Create < Expense::Manual::Multiple::Base
  attr_accessor :valid, :errors_by_expenses, :multiple_expenses_params, :multiple_expenses

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
    # Multiple Expense params
    self.multiple_expenses_params = params[:multiple]

    # Will hold errors for each expense when validating
    self.errors_by_expenses = {}

    # Will contain all initialized expenses created from params
    self.multiple_expenses = {}

    # If valid is true then will start creating expenses
    self.valid = true

    for key, params_each_expense in multiple_expenses_params #value is params for Validate Class

      # creating strong params out of params received
      current_expense_params = manual_multiple_expense_params(params_each_expense)

      current_expense_params[:expense_type_id] = ExpenseType.manual_expense_id

      # Setting index for current expense to initialize
      multiple_expenses[key] = {}

      # Creating receipt object if receipt id is sent
      if params_each_expense[:receipt_id].present?
        self.multiple_expenses[key][:receipt] = user.receipts.with_id(params_each_expense[:receipt_id]).first rescue nil
      end

      # Removing receipts attributes from strong params, if empty
      if current_expense_params[:receipts_attributes] == [nil] or current_expense_params[:receipts_attributes] == ['']
        current_expense_params.except!(:receipts_attributes)
      end

      # Initializing expense out of strong params
      self.multiple_expenses[key][:expense] = user.expenses.new(current_expense_params)

      # Storing strong params for reference
      self.multiple_expenses[key][:params] = current_expense_params

      # Initializing custom fields for current expense
      set_custom_fields_multiple(self.multiple_expenses[key][:expense], params_each_expense)

    end

  end

  def validate
    # MISSING
    # Adding expense to reports, check validation for report editable

    for key, value in self.multiple_expenses
      # Setting errors for the current expense
      self.errors_by_expenses[key] = {error: []}

      # Adding model level validation errors
      self.errors_by_expenses[key][:error] += value[:expense].errors.full_messages unless value[:expense].valid?

      valid = CustomField::Validate.(value[:expense].manual_expense)
      unless valid.success?
        # Adding custom field validation errors
        self.errors_by_expenses[key][:error] += valid.messages[:error]
      end

      # Setting flag false if errors are found
      if self.errors_by_expenses[key][:error].present?
        self.valid = false
      end
    end
  end

  def process
    if self.valid
      # Will start creating expenses, since no errors are found
      for key, value in self.multiple_expenses
        if value[:expense].save

          # Attach an existing receipt to the expense
          if value[:receipt].present?
            value[:receipt].parent = value[:expense]

            # Updating receipt
            value[:receipt].save
          end
        end
      end
      add_message :success, "Created #{self.multiple_expenses.values.length} expenses successfully."
    else
      # Hack
      make_expenses_invalid(self.multiple_expenses)
      add_message :failure, 'Cannot create expenses. Please fix the errors and try again.'
    end
  end


  # Hack
  def make_expenses_invalid(h)
    # WEIRD BUG: JIRA TICKET ID: FIN-411
    # After rendering the error json file, its saving the valid expenses
    # Making expenses invalid is the only way to stop this from happening
    # Needs further investigation to remove the bug
    for key, expense in h
      expense[:expense].amount = nil
    end
  end

  def post_process
    self.multiple_expenses.each { |expense| Expense::Manual::Duplicate::ProcessDuplicate.(user, expense: expense) }
  end

  def set_custom_fields_multiple(expense, current_params)
    custom_fields = {custom_fields: (current_params[:custom_fields] or current_params[:expense][:custom_fields])}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = false
    CustomField::SetFields.(expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
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
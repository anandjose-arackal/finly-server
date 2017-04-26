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
    self.multiple_expenses_params = params[:multiple]
    self.errors_by_expenses = {}
    self.multiple_expenses = {}
    self.valid = true

    for key, params_each_expense  in multiple_expenses_params #value is params for Validate Class

      current_expense_params = manual_multiple_expense_params(params_each_expense)
      current_expense_params[:expense_type_id] = ExpenseType.manual_expense_id
      multiple_expenses[key] = {}

      # Removing receipt_attrib if empty
      if current_expense_params[:receipt_id].present?
        self.multiple_expenses[key][:receipt] = user.receipts.with_id(current_expense_params[:receipt_id]).first rescue nil
      end
      if current_expense_params[:receipts_attributes] == [nil] or current_expense_params[:receipts_attributes] == ['']
        current_expense_params.delete(:receipts_attributes)
      end


      self.multiple_expenses[key][:expense] = user.expenses.new(current_expense_params)
      
      self.multiple_expenses[key][:params] = current_expense_params
      set_custom_fields_multiple(self.multiple_expenses[key][:expense], params_each_expense)

      # self.errors_by_expenses[key] = expense.messages
      # unless self.errors_by_expenses[key][:error].blank? && self.errors_by_expenses[key][:failure].blank?
      #   self.valid = false
      # end
    end

  end

  def validate
    # debugger
    # # self.valid = true
    for key, value in self.multiple_expenses
      self.errors_by_expenses[key] = {}
      self.errors_by_expenses[key][:error] = []
      self.errors_by_expenses[key][:error] += value[:expense].errors.full_messages unless value[:expense].valid?
      valid = CustomField::Validate.(value[:expense].manual_expense)
      unless valid.success?
        # self.errors_by_expenses[key][:error] ||= []
        self.errors_by_expenses[key][:error] += valid.messages[:error]
      end
      if self.errors_by_expenses[key][:error].present?
        self.valid = false
      end
    end

    # debugger
  end

  def process
    debugger
    if self.valid

      for key, value in self.multiple_expenses
        if value[:expense].save
          # Attach an existing receipt to the expense
          if value[:receipt].present?
            value[:receipt].parent = expense
            value[:receipt].save
          end
        end
      end
      # expenses = params[:multiple]
      # for key, value in expenses
      #   expense = Expense::Manual::Create.(user, value)
      #   # debugger
      # end
      add_message :success, "Created #{self.multiple_expenses.values.length} expenses successfully."
    else
      add_message :failure, 'Cannot create expenses. Please fix the errors and try again.' 
    end
  end

  def post_process

  end

  def set_custom_fields_multiple(expense, current_params)
    # debugger
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
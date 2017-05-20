# operation to create a distance expense
# parameters :
# expense: { distance_expense_attributes: { distance_attributes: { value:  of the distance in km
#                                                                }
#                                         }
#            note: "Sample note"
#            category_id: 2
#            date: "25-01-17"
#            expense_type_id: 3
#            expense_status_id: 4
#          }
# type: '3' for distance expense
# }


class Expense::ExDistance::Multiple::Create < Expense::ExDistance::Multiple::Base

  attr_accessor :valid, :errors_by_expenses, :multiple_expense_params, :multiple_expenses

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters passed'
    end
    if params[:multiple].blank?
      messages[:error] << 'Provide details for at least one expense to proceed'
      return
    end
    # distance_value = params[:expense][:distance_expense_attributes][:distance_attributes][:value].to_d rescue nil
    # if distance_value.present? and distance_value <= 0
    #   messages[:error] << 'Distance cannot be less than or equal to 0'
    # end
  end

  def init
    self.multiple_expense_params = params[:multiple]

    self.errors_by_expenses = {}

    self.multiple_expenses = {}

    self.valid = true

    for key, params_each_expense in multiple_expense_params

      current_expense_params = distance_multiple_expense_params(params_each_expense)

      current_expense_params[:expense_type_id] = ExpenseType.distance_expense_id

      multiple_expenses[key] = {}

      if params_each_expense[:receipt_id].present?
        self.multiple_expenses[key][:receipt] = user.receipts.with_id(params_each_expense[:receipt_id]).first rescue nil
      end

      if current_expense_params[:receipts_attributes] == [nil] or current_expense_params[:receipts_attributes] == ['']
        current_expense_params.except!(:receipts_attributes)
      end


      self.multiple_expenses[key][:expense] = user.expenses.new(current_expense_params)

      self.multiple_expenses[key][:params] = current_expense_params

      set_custom_fields_multiple(self.multiple_expenses[key][:expense], params_each_expense)
    end









    # self.expense_params = distance_expense_params
    # self.expense_params[:expense_type_id] = ExpenseType.distance_expense_id
    # if params[:receipt_id].present?
    #   self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    # end
    # if expense_params[:receipts_attributes] == [nil]
    #   expense_params.delete(:receipts_attributes)
    # end
  end

  def validate
    debugger
    unless user.distance_expense_enabled?
      add_message :error, "Distance expense creation is not enabled"
      return false
    end

    # checking if the report is editable for personal view
    # if personal_view? and params[:report_id].present?
    #   report = user.reports.find_by(id: expense_params[:report_id])
    #   unless report.editable?
    #     add_message :error, "Expense cannot be added to the report in this state"
    #   end
    # end

    for key, value in self.multiple_expenses
      # Setting errors for the current expense
      self.errors_by_expenses[key] = { error: [] }

      # Adding model level validation errors
      self.errors_by_expenses[key][:error] += value[:expense].errors.full_messages unless value[:expense].valid?

      if personal_view? && value[:params][:report_id].present?
        report = user.reports.find_by(id: value[:params][:report_id])
        unless report.editable?
          self.errors_by_expenses[key][:error].push("Expense cannot be added to report in this state.")
        end
      end

      valid = CustomField::Validate.(value[:expense].distance_expense)
      unless valid.success?
        # Adding custom field validation errors
        self.errors_by_expenses[key][:error] += valid.messages[:error]
      end

      # Setting flag false if errors are found
      if self.errors_by_expenses[key][:error].present?
        self.valid = false
      end
    end













    # if expense_params[:receipt_id].present? and receipt.blank?
    #   messages[:error] << 'Receipt not found'
    #   return false
    # end

    # # checking if distance expense has been enabled for the user at the company or policy level
    # unless user.distance_expense_enabled?
    #   add_message :error, "Distance expense creation is not enabled"
    #   return false
    # end

    # checking if the report is editable for personal view
    # if personal_view? and expense_params[:report_id].present?
    #   report = user.reports.find_by(id: expense_params[:report_id])
    #   unless report&.editable?
    #     messages[:error] << "Expense cannot be added to the report in this state"
    #   end
    # end
  end

  def process
    if self.valid
      for key, value in self.multiple_expenses
        if value[:expense].save
          if value[:receipt].present?
            value[:receipt].parent = value[:expense]

            value[:receipt].save
          end
        end
      end

      add_message :success, "Created #{self.multiple_expenses.values.length} expenses successfully."

    else
      add_message :failure, "Cannot create expenses. Please fix the errors and try again."
    end





    # self.expense = user.expenses.build(expense_params)

    # # Create custom fields only for validations. Fields will be saved later
    # validate_custom_fields
    # return if has_errors?

    # if self.expense.save
    #   # Attach an existing receipt to the expense
    #   if self.receipt.present?
    #     self.receipt.parent = expense
    #     self.receipt.save
    #   end
    # else
    #   messages[:error] = self.expense.errors.full_messages
    # end
  end

  def post_process
    # # add comment in report if expense is added within report
    # if self.expense.report_id.present? and self.expense.report.retracted?
    #   comment = self.expense.report.comments.build report: self.expense.report, user: user,
    #                                                report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
    #   unless comment.save
    #     messages[:error] = comment.errors.full_messages
    #   end
    # end
    # # if the expense is part of a report, calculate the associated amount
    # if expense_params[:report_id].present?
    #   report = user.reports.find_by(id: expense_params[:report_id])
    #   amount = expense.amount
    #   if amount.nil?
    #     amount_params = {value: expense.calculate_amount_value(report.policy), currency_id: Currency.first.id}
    #     amount = Amount.create(amount_params)
    #   else
    #     amount.update(value: expense.calculate_amount_value(report.policy))
    #   end
    #   expense.update_attributes(amount_id: amount.id)

    #   # calculate the equivalent amount in all currencies in the amounts table
    #   if expense.date == DateUtils.local_date
    #     expense.amount.update(expense.amount.currency.country_code.to_sym => expense.amount_value)
    #   else
    #     expense.update_other_currencies
    #   end
    # end

    # messages[:success] << 'Expense created'
  end

  # protected
  # def validate_custom_fields
  #   if self.expense.valid?
  #     set_fields = set_custom_fields false
  #     unless set_fields.success?
  #       add_message :error, set_fields.messages[:error]
  #       return
  #     end
  #     valid = CustomField::Validate.(self.expense.distance_expense)
  #     unless valid.success?
  #       add_message :error, valid.messages[:error]
  #       return
  #     end
  #   end
  # end

  # def set_custom_fields(save)
  #   custom_fields = {custom_fields: params[:custom_fields]}
  #   custom_fields[:user] = user
  #   custom_fields[:reset_fields] = true
  #   custom_fields[:save] = save
  #   CustomField::SetFields.(self.expense.distance_expense, FieldParentType.id_for(:distance_expense), custom_fields)
  # end

  def set_custom_fields_multiple(expense, current_params)
    custom_fields = {custom_fields: (current_params[:custom_fields] or current_params[:expense][:custom_fields])}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = false
    # debugger
    CustomField::SetFields.(expense.distance_expense, FieldParentType.id_for(:distance_expense), custom_fields)
  end

  def failure
    params[:expense_errors] = self.errors_by_expenses
    Expense::ExDistance::Multiple::Base::FailurePresenter.new(user, params, messages)
  end

  class Expense::ExDistance::Multiple::Base::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :expense_errors
    def init
      self.expense_errors = params[:expense_errors]
    end

    def formatted_messages
      self.expense_errors
    end
  end

end
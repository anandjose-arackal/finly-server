# operation to create a time expense
# parameters :
# expense: { time_expense_attributes: { time_object_attributes: { value:  of the time
#                                                                }
#                                         }
#            note: "Sample note"
#            category_id: 2
#            date: "25-01-17"
#            expense_type_id: 4
#            expense_status_id: 4
#          }
# type: '4' for time expense
# }

class Expense::ExTime::Multiple::Create < Expense::ExTime::Multiple::Base

  attr_accessor :valid, :errors_by_expenses, :multiple_expense_params, :multiple_expenses

  def personalizer
    {
        pre_process: {
            before: Personalizer::Process.new([:expense, :time_multiple_create], :pre_process, self)
        }
    }
  end

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters passed"
    end
    if params[:multiple].blank?
      add_message :error, 'Provide details for at least one expense to proceed'
      return
    end
    # time_value = params[:expense][:time_expense_attributes][:time_object_attributes][:value].to_d rescue nil
    # if time_value.present? and time_value <= 0
    #   add_message :error, 'Time cannot be less than or equal to 0'
    # end
  end

  def init
    self.multiple_expense_params = params[:multiple]

    self.errors_by_expenses = {}

    self.multiple_expenses = {}

    self.valid = true

    for key, params_each_expense in multiple_expense_params

      current_expense_params = extime_multiple_expense_params(params_each_expense)

      current_expense_params[:expense_type_id] = ExpenseType.time_expense_id

      pocket_id = current_expense_params[:spent_from_id]
      if pocket_id.blank?
        reimbursable = params_each_expense&.dig(:expense, :reimbursable)
        from_cash_on_hand = params_each_expense&.dig(:expense, :from_cash_on_hand)
        if reimbursable
          pocket_id = user.user_pockets.reimbursement_pocket_only&.first&.id
        elsif from_cash_on_hand
          pocket_id = user.user_pockets.cash_pockets_only&.first&.id
        else
          pocket_id = user.user_pockets.paid_by_company_pocket_only&.first&.id
        end
      end
      cash_pocket = user.user_pockets.non_bank_card_transfer_pockets.find_by(id: pocket_id)

      if cash_pocket.blank?
        cash_pocket = user.user_pockets.cash_pockets_only.first
      end
      current_expense_params[:spent_from_id] = cash_pocket&.id

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
  end

  def validate

    unless user.time_expense_enabled?
      add_message :error, "Time expense creation is not enabled"
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

      expense = value[:expense]
      if expense.reimbursable && expense.from_cash_on_hand
        self.errors_by_expenses[key][:error] += ["Expense cannot be both reimbursable and from cash on hand"]
      end

      if personal_view? && value[:params][:report_id].present?
        report = user.reports.find_by(id: value[:params][:report_id])
        unless report.editable?
          self.errors_by_expenses[key][:error].push("Expense cannot be added to report in this state.")
        end
      end

      valid = CustomField::Validate.(value[:expense].time_expense)
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
    #   add_message :error, 'Receipt not found'
    #   return false
    # end

    # # checking if time expense has been enabled for the user at the company or policy level
    # unless user.time_expense_enabled?
    #   add_message :error, "Time expense creation is not enabled"
    #   return false
    # end

    # # checking if the report is editable for personal view
    # if personal_view? and expense_params[:report_id].present?
    #   report = user.reports.find_by(id: expense_params[:report_id])
    #   unless report.editable?
    #     add_message :error, "Expense cannot be added to the report in this state"
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
      make_expenses_invalid(self.multiple_expenses)
      add_message :failure, "Cannot create expenses. Please fix the errors and try again."
    end








    # self.expense = user.expenses.build(expense_params)

    # validate_custom_fields
    # return if has_errors?

    # if self.expense.save
    #   if self.receipt.present?
    #     self.receipt.parent = expense
    #     self.receipt.save
    #   end
    # else
    #   add_message :error, self.expense.errors.full_messages
    # end
  end

  # Hack
  def make_expenses_invalid(h)
    # WEIRD BUG: JIRA TICKET ID: FIN-411
    # After rendering the error json file, its saving the valid expenses
    # Making expenses invalid is the only way to stop this from happening
    # Needs further investigation to remove the bug
    for key, expense in h
      expense[:expense].date = nil
    end
  end

  def post_process
    if self.valid
      for key, value in self.multiple_expenses
        # Add Report Comment
        if value[:expense].report_id.present? and value[:expense].report.retracted?
          comment = value[:expense].report.comments.build report: value[:expense].report, user: user,
                                                       report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: value[:expense]
          unless comment.save
            messages[:error] = comment.errors.full_messages
          end
        end


        # if the expense is part of a report, calculate the associated amount
        if value[:expense].report.present?
          report = user.reports.find_by(id: value[:expense].report.id)
          amount = value[:expense].amount
          if amount.nil?
            amount_params = {value: value[:expense].calculate_amount_value(report.policy), currency_id: Currency.first.id}
            amount = Amount.create(amount_params)
          else
            amount.update(value: value[:expense].calculate_amount_value(report.policy))
          end
          value[:expense].update_attributes(amount_id: amount.id)

          # calculate the equivalent amount in all currencies in the amounts table
          if value[:expense].date == DateUtils.local_date
            value[:expense].amount.update(value[:expense].amount.currency.country_code.to_sym => value[:expense].amount_value)
          else
            value[:expense].update_other_currencies
          end
        end

        expense = value[:expense]
        # check if this expense's amount allows for it to be marked against COH
        # and if it is or is not, update the flag for this expense accordingly
        if expense.amount.present? && expense.from_cash_on_hand
          pocket = expense.spent_from
          pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
          if pocket_adapter.balance(display_balance: true) > expense.amount_value
            expense.update(cash_on_hand_blocked: true)
          end
          if pocket_adapter.balance(display_balance: true) < 0
            expense.update(cash_on_hand_blocked: false)
          end
        end
      end
    end
  end

  # protected
  # def validate_custom_fields
  #   if self.expense.valid?
  #     set_fields = set_custom_fields false
  #     unless set_fields.success?
  #       add_message :error, set_fields.messages[:error]
  #       return
  #     end
  #     valid = CustomField::Validate.(self.expense.time_expense)
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
  #   CustomField::SetFields.(self.expense.time_expense, FieldParentType.id_for(:time_expense), custom_fields)
  # end

  def set_custom_fields_multiple(expense, current_params)
    custom_fields = {custom_fields: (current_params[:custom_fields] or current_params[:expense][:custom_fields])}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = false

    CustomField::SetFields.(expense.time_expense, FieldParentType.id_for(:time_expense), custom_fields)
  end

  def failure
    params[:expense_errors] = self.errors_by_expenses
    Expense::ExTime::Multiple::Base::FailurePresenter.new(user, params, messages)
  end

  class Expense::ExTime::Multiple::Base::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :expense_errors
    def init
      self.expense_errors = params[:expense_errors]
    end

    def formatted_messages
      self.expense_errors
    end
  end

end
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

class Expense::ExTime::Create < Expense::ExTime::Base

  attr_accessor :expense_params, :receipt

  def personalizer
    {
        pre_validate: {
            before: Personalizer::Process.new([:expense, :time_create], :pre_validate, self)
        },
        pre_process: {
            before: Personalizer::Process.new([:expense, :time_create], :pre_process, self)
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
    if params[:expense].blank?
      add_message :error, 'You have not provided any details to create an expense'
      return
    end
  end

  def init
    self.expense_params = time_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.time_expense_id
    if params[:receipt_id].present?
      self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    end
    if expense_params[:receipts_attributes] == [nil] or expense_params[:receipts_attributes] == ['']
      expense_params.delete(:receipts_attributes)
    end

    pocket_id = self.params&.dig(:expense, :spent_from_id)
    # Todo - Jugaad - Legacy support for older version of android/iOS where this is not implemented
    if pocket_id.blank? and (params[:expense].present? and params[:expense].has_key?(:reimbursable) and params[:expense].has_key?(:from_cash_on_hand))
      reimbursable = params&.dig(:expense, :reimbursable)
      from_cash_on_hand = params&.dig(:expense, :from_cash_on_hand)
      if reimbursable
        pocket_id = user.user_pockets.reimbursement_pocket_only&.first&.id
      elsif from_cash_on_hand
        pocket_id = user.user_pockets.cash_pockets_only&.first&.id
      else
        pocket_id = user.user_pockets.paid_by_company_pocket_only&.first&.id
      end
      if pocket_id.blank?
        pocket_id = user.user_pockets.cash_pockets_only.first&.id
      end
    end
    # Jugaad End
    if pocket_id.present?
      self.cash_pocket = user.user_pockets.non_bank_card_transfer_pockets.find_by(id: pocket_id)
      self.expense_params[:spent_from_id] = self.cash_pocket&.id
    end
  end

  def validate
    if expense_params[:receipt_id].present? and receipt.blank?
      add_message :error, 'Receipt not found'
      return false
    end

    # checking if time expense has been enabled for the user at the company or policy level
    unless user.time_expense_enabled?
      add_message :error, "Time expense creation is not enabled"
      return false
    end

    if self.expense_params[:spent_from_id].blank?
      add_message :error, 'Please select the Spend Account'
      return
    end

    if self.expense_params[:spent_from_id].present? && self.cash_pocket.blank?
      add_message :error, 'Error in Spend Account'
      return
    end

    # checking if the report is editable for personal view
    if personal_view? and expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      unless report.editable?
        add_message :error, "Expense cannot be added to the report in this state"
      end
    end

    # ensuring that a particular expense cannot be both from cash on hand and reimbursable at the same time
    check_coh_availability_create(self.cash_pocket, expense_params)

    # ensuring that a particular expense cannot be both from cash on hand and reimbursable at the same time
    check_coh_reimbursable_exclusivity_create(expense_params)
  end

  def pre_process
    # if the expense is from cash on hand, mark it as non-reimbursable by default
    if StringUtils.to_bool(expense_params[:from_cash_on_hand]) || expense_params[:spent_from_id].present?
      expense_params[:reimbursable] = false
    end

    # conversely if the expense is marked as reimbursable, automatically make it not from any cash pocket
    if StringUtils.to_bool(expense_params[:reimbursable])
      expense_params[:spent_from_id] = nil
    end
    expense_params[:created_by_id] = actual_current_user.id if actual_current_user.present?
  end

  def process
    self.expense = user.expenses.build(expense_params)

    validate_custom_fields
    return if has_errors?

    if self.expense.save
      if self.receipt.present?
        self.receipt.parent = expense
        self.receipt.save
      end
    else
      add_message :error, self.expense.errors.full_messages
    end
  end

  def post_process
    # add comment in report if expense is added within report
    if self.expense.report_id.present? and self.expense.report.retracted?
      comment = self.expense.report.comments.build report: self.expense.report, user: user,
                                                   report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
      unless comment.save
        messages[:error] = comment.errors.full_messages
      end
    end
    # if the expense is part of a report, calculate the associated amount
    if expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      amount = expense.amount
      if amount.nil?
        amount_params = {value: expense.calculate_amount_value(report.policy), currency_id: expense.report.policy.base_currency_id}
        amount = Amount.create(amount_params)
      else
        amount.update(value: expense.calculate_amount_value(report.policy), currency_id: expense.report.policy.base_currency_id)
      end
      expense.update_attributes(amount_id: amount.id)

      # calculate the equivalent amount in all currencies in the amounts table
      if expense.date == DateUtils.local_date
        expense.amount.update(expense.amount.currency.country_code.to_sym => expense.amount_value)
      else
        expense.update_other_currencies
      end
    end

    # check if this expense's amount allows for it to be marked against COH
    # and if it is or is not, update the flag for this expense accordingly
    if expense.amount.present? && expense.from_cash_on_hand
      pocket = expense.spent_from
      if pocket.cash_pocket?
        pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
        if pocket_adapter.balance(display_balance: true) > expense.amount_value
          expense.update(cash_on_hand_blocked: true)
        end
        if pocket_adapter.balance(display_balance: true) < 0
          expense.update(cash_on_hand_blocked: false)
        end
      elsif pocket.credit_card_pocket?
        expense.update(cash_on_hand_blocked: true)
      end
    end

    # checking if the expense has any receipts, and marking them all as no need to be transcribed
    if expense.receipts.present?
      expense.receipts.update_all(to_be_transcribed: false)
    end

    add_message :success, 'Expense created'
  end

  protected
  def validate_custom_fields
    if self.expense.valid?
      set_fields = set_custom_fields false
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return
      end
      valid = CustomField::Validate.(self.expense.time_expense)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return
      end
    end
  end

  def set_custom_fields(save)
    custom_fields = {custom_fields: params[:custom_fields]}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(self.expense.time_expense, FieldParentType.id_for(:time_expense), custom_fields)
  end

end
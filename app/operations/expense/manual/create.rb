# Class to create an expense
# format of parameters,

class Expense::Manual::Create < Expense::Manual::Base
  attr_accessor :expense_params, :receipt

  def personalizer
    {
        pre_validate: {
            before: Personalizer::Process.new([:expense, :manual_create], :pre_validate, self)
        },
        pre_process: {
            before: Personalizer::Process.new([:expense, :manual_create], :pre_process, self)
        }
    }
  end

  # only employees can create expenses
  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super
    if params.blank?
      add_message :error, 'Parameters not present'
    end
    if params[:expense].blank?
      add_message :error, 'You have not provided any details to create an expense'
      return
    end
    amount_value = params[:expense][:amount_attributes][:value].to_d rescue nil
    if amount_value.present? and amount_value <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
    end
  end

  def init
    self.expense_params = manual_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.manual_expense_id
    if params[:receipt_id].present?
      self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    end
    if expense_params[:receipts_attributes] == [nil] or expense_params[:receipts_attributes] == ['']
      expense_params.delete(:receipts_attributes)
    end

    pocket_id = self.expense_params[:spent_from_id]
    if pocket_id.blank?
      reimbursable = params&.dig(:expense, :reimbursable)
      from_cash_on_hand = params&.dig(:expense, :from_cash_on_hand)
      if reimbursable
        pocket_id = user.user_pockets.reimbursement_pocket_only&.first&.id
      elsif from_cash_on_hand
        pocket_id = user.user_pockets.cash_pockets_only&.first&.id
      else
        pocket_id = user.user_pockets.paid_by_company_pocket_only&.first&.id
      end
    end
    self.cash_pocket = user.user_pockets.non_bank_card_transfer_pockets.find_by(id: pocket_id)

    if self.cash_pocket.blank?
      self.cash_pocket = user.user_pockets.cash_pockets_only.first
    end
    self.expense_params[:spent_from_id] = self.cash_pocket&.id
  end

  def validate
    # can't think of anything for now
    if expense_params[:receipt_id].present? and receipt.blank?
      add_message :error, 'Receipt not found'
      return false
    end

    # checking if the report is editable for personal view
    if personal_view? and expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      unless report.editable?
        add_message :error, 'Expense cannot be added to the report in this state'
      end
    end

    if self.expense_params[:spent_from_id].present? && self.cash_pocket.blank?
      add_message :error, "Could not find pocket from which this expense was spent"
      return
    end

    # checking if the user has enough cash on hand balance to mark this expense against it
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
  end

  def process
    self.expense = user.expenses.build(expense_params)
    # Create custom fields only for validations. Fields will be saved later
    validate_custom_fields
    return if has_errors?

    if self.expense.save
      # Attach an existing receipt to the expense
      if self.receipt.present?
        self.receipt.parent = expense
        self.receipt.save
      end
    else
      add_message :error, self.expense.errors.full_messages
    end
  end

  def post_process
    if expense&.receipt_email.present? and not params[:prevent_email_process]
      Receipt::ReceiptEmails::ProcessEmail.call_async(user, receipt_email_id: self.expense.receipt_email.id)
    end

    # calculate the equivalent amount in all currencies in the amounts table
    if expense.date == DateUtils.local_date
      expense.amount.update(expense.amount.currency.country_code.to_sym => expense.amount_value)
    else
      expense.update_other_currencies
    end

    Expense::Manual::Duplicate::ProcessDuplicate.(user, expense: self.expense)

    # add comment in report if expense is added within report
    if self.expense.report_id.present? and self.expense.report.retracted?
      comment = self.expense.report.comments.build report: self.expense.report, user: user,
                                                   report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
      unless comment.save
        add_message :error, comment.errors.full_messages
      end
    end

    # marking this expense as blocked against cash on hand, because it's a manual expense
    expense.update(cash_on_hand_blocked: true)
    ##########--------------------------############

    # checking if the expense has any receipts, and marking them all as no need to be transcribed
    if expense.receipts.present?
      expense.receipts.update_all(to_be_transcribed: false)
    end

    add_message :success, 'Expense created'
  end

  def success
    params[:expense] = self.expense
    Expense::Manual::Create::SuccessPresenter.new(user, params, messages)
  end

  protected
  def validate_custom_fields
    if self.expense.valid?
      set_fields = set_custom_fields false
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return
      end
      valid = CustomField::Validate.(self.expense.manual_expense)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return
      end
      # self.expense.manual_expense.custom_fields.destroy_all
    end
  end

  def set_custom_fields(save)
    custom_fields = {custom_fields: (params[:custom_fields] or params[:expense][:custom_fields])}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(self.expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
  end

  class Expense::Manual::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :expense

    def init
      self.expense = params[:expense]
    end
  end

end
class Expense::ExPerDiem::Create < Expense::ExPerDiem::Base

  attr_accessor :expense_params, :receipt, :per_diem

  def personalizer
    {
        pre_validate: {
            before: Personalizer::Process.new([:expense, :per_diem_create], :pre_validate, self)
        },
        pre_process: {
            before: Personalizer::Process.new([:expense, :per_diem_create], :pre_process, self)
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
      messages[:error] << 'You have not provided any details to create an expense'
      return
    end
    quantity_value = params[:expense][:per_diem_expense_attributes][:quantity].to_d rescue nil
    if quantity_value.present? and quantity_value <= 0
      messages[:error] << 'Quantity cannot be less than or equal to 0'
    end
    per_diem_id = params[:expense][:per_diem_expense_attributes][:per_diem_id].to_d rescue nil
    self.per_diem = PerDiem.find_from_id(per_diem_id)
    if per_diem.blank?
      add_message :error, "You have to select an associated per diem"
    end
  end

  def init
    self.expense_params = per_diem_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.per_diem_expense_id
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
      messages[:error] << 'Receipt not found'
      return false
    end

    # checking if per_diem expense has been enabled for the user at the company or policy level
    unless user.per_diem_expense_enabled?
      add_message :error, 'Per Diem expense creation is not enabled'
      return false
    end

    # checking if the report is editable for personal view
    if personal_view? and expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      unless report.editable?
        messages[:error] << 'Expense cannot be added to the report in this state'
      end
    end

    if self.expense_params[:spent_from_id].blank?
      add_message :error, 'Please select the Spend Account'
      return
    end

    if self.expense_params[:spent_from_id].present? && self.cash_pocket.blank?
      add_message :error, 'Error in Spend Account'
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
    expense_params[:created_by_id] = actual_current_user.id if actual_current_user.present?
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
      messages[:error] = self.expense.errors.full_messages
    end
  end

  def post_process

    # calculate amount of the expense
    amount = expense.amount
    if amount.blank?
      amount = Amount.create(value: expense.calculate_amount_value(per_diem.configurable), currency_id: per_diem.configurable.base_currency_id)
      expense.update(amount: amount)
    else
      amount.update(value: expense.calculate_amount_value(per_diem.configurable), currency_id: per_diem.configurable.base_currency_id)

      # calculate the equivalent amount in all currencies in the amounts table
      if expense.date == DateUtils.local_date
        expense.amount.update(expense.amount.currency.country_code.to_sym => expense.amount_value)
      else
        expense.update_other_currencies
      end
    end

    # marking the expense as reconciled with cash on hand because the amount is known
    expense.update(cash_on_hand_blocked: true)
    ##########--------------------------############

    # checking if the expense has any receipts, and marking them all as no need to be transcribed
    if expense.receipts.present?
      expense.receipts.update_all(to_be_transcribed: false)
    end

    # add comment in report if expense is added within report
    if self.expense.report_id.present? and self.expense.report.retracted?
      comment = self.expense.report.comments.build report: self.expense.report, user: user,
                                                   report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
      unless comment.save
        messages[:error] = comment.errors.full_messages
      end
    end

    messages[:success] << 'Expense created'
  end

  protected
  def validate_custom_fields
    if self.expense.valid?
      set_fields = set_custom_fields false
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return
      end
      valid = CustomField::Validate.(self.expense.per_diem_expense)
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
    CustomField::SetFields.(self.expense.per_diem_expense, FieldParentType.id_for(:per_diem_expense), custom_fields)
  end

end
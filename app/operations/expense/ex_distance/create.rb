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


class Expense::ExDistance::Create < Expense::ExDistance::Base

  attr_accessor :expense_params, :receipt

  def personalizer
    {
        process: {
            before: Personalizer::Process.new([:expense, :distance_create], :process, self)
        },
        pre_process: {
            before: Personalizer::Process.new([:expense, :distance_create], :pre_process, self)
        }
    }
  end

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters passed'
    end
    if params[:expense].blank?
      messages[:error] << 'You have not provided any details to create an expense'
      return
    end
    distance_value = params[:expense][:distance_expense_attributes][:distance_attributes][:value].to_d rescue nil
    if distance_value.present? and distance_value <= 0
      messages[:error] << 'Distance cannot be less than or equal to 0'
    end
  end

  def init
    self.expense_params = distance_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.distance_expense_id
    if self.expense_params[:distance_attributes].present?
      self.expense_params[:distance_attributes][:type_id] = DistanceExpenseType.id_for(:distance)
    end
    if params[:receipt_id].present?
      self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    end
    if expense_params[:receipts_attributes] == [nil] or expense_params[:receipts_attributes] == ['']
      expense_params.delete(:receipts_attributes)
    end

    # Setting order for each of the locations
    pos = 1
    self.expense_params&.dig(:distance_expense_attributes)&.dig(:locations_attributes)&.each do |location|
      location[:order] = pos
      pos += 1
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
    self.cash_pocket = user.user_pockets.cash_and_credit_cards.find_by(id: pocket_id)

    if self.cash_pocket.blank?
      self.cash_pocket = user.user_pockets.cash_pockets_only.first
    end
    self.expense_params[:spent_from_id] = self.cash_pocket&.id
  end

  def validate
    if expense_params[:receipt_id].present? and receipt.blank?
      messages[:error] << 'Receipt not found'
      return false
    end

    # checking if distance expense has been enabled for the user at the company or policy level
    unless user.distance_expense_enabled?
      add_message :error, "Distance expense creation is not enabled"
      return false
    end

    # checking if the report is editable for personal view
    if personal_view? and expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      unless report&.editable?
        messages[:error] << "Expense cannot be added to the report in this state"
      end
    end

    if self.expense_params[:spent_from_id].present? && self.cash_pocket.blank?
      add_message :error, "Could not find pocket from which this expense was spent"
      return
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
  end

  def process
    self.expense = user.expenses.build(expense_params)

    if self.expense.distance_expense&.vehicle_rate&.policy&.distance_expense_config&.enforce_category
      self.expense.category = self.expense.distance_expense&.vehicle_rate&.policy&.distance_expense_config&.default_category
    end

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
    # add comment in report if expense is added within report
    if self.expense.report_id.present? and self.expense.report.retracted?
      comment = self.expense.report.comments.build report: self.expense.report, user: user,
                                                   report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
      unless comment.save
        messages[:error] = comment.errors.full_messages
      end
    end
    # if the expense is part of a report, calculate the associated amount
    # if expense_params[:report_id].present?
    #   report = user.reports.find_by(id: expense_params[:report_id])
    amount = expense.amount
    currency_id = expense.distance_expense.vehicle_rate&.rate&.currency_id
    if amount.nil?
      amount_params = {value: expense.calculate_amount_value, currency_id: currency_id}
      amount = Amount.create(amount_params)
    else
      amount.update(value: expense.calculate_amount_value, currency_id: currency_id)
    end
    expense.update_attributes(amount_id: amount.id)

    if expense.amount.present?
      # calculate the equivalent amount in all currencies in the amounts table
      if expense.date == DateUtils.local_date
        expense.amount.update(expense.amount.currency.country_code.to_sym => expense.amount_value)
      else
        expense.update_other_currencies
      end
    end
    # end

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
      valid = CustomField::Validate.(self.expense.distance_expense)
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
    CustomField::SetFields.(self.expense.distance_expense, FieldParentType.id_for(:distance_expense), custom_fields)
  end

end
# action to update an expense.
# params:
# expense_id, or id : the id of the expense that us going to be edited.
#

class Expense::Manual::Update < Expense::Manual::Base
  attr_accessor :updated_expense_params
  attr_accessor :editable_attrs, :receipt, :old_receipt, :destroy_receipts, :stored_custom_fields
  attr_accessor :original_attributes

  def personalizer
    {
        pre_validate: {
            before: Personalizer::Process.new([:expense, :manual_update], :pre_validate, self)
        },
        pre_process: {
            before: Personalizer::Process.new([:expense, :manual_update], :pre_process, self)
        }
    }
  end

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << 'Parameters or user not found'
      return false
    end
    if params[:expense_id].nil? and params[:id].blank?
      messages[:error] << 'Expense ID missing'
      return false
    end
    amount_value = params[:expense][:amount_attributes][:value].to_d rescue nil
    if amount_value.present? and amount_value <= 0
      messages[:error] << 'Amount cannot be less than or equal to 0'
    end
    validate_delegator_action if actual_current_user.present?
  end

  def init
    super
    # saving previous expense attributes before updation
    define_editable_attributes if expense
    # setting up the expense params for updation
    self.updated_expense_params = manual_expense_params
    if updated_expense_params[:receipts_attributes] == [nil] or updated_expense_params[:receipts_attributes] == [""]
      # if the receipts attributes is passed as [""], the receipt attached to this expense gets disassociated
      # todo - check if the api fails because of this
      if updated_expense_params[:receipts_attributes] == ['']
        self.destroy_receipts = true
      end
      updated_expense_params.delete(:receipts_attributes)
    end
    if expense
      if self.updated_expense_params[:amount_attributes].present? and self.updated_expense_params[:amount_attributes][:value].present? and
          expense.amount_id.present?
        self.updated_expense_params[:amount_attributes][:id] = expense.amount.id
      end
      if self.updated_expense_params[:manual_expense_attributes].present? and self.expense.manual_expense.id.present?
        self.updated_expense_params[:manual_expense_attributes][:id] = expense.manual_expense.id if expense
      end
      if expense.receipts.present? and updated_expense_params[:receipts_attributes].present?
        self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
      end
      if params[:receipt_id].present?
        # If a new receipt is attached from existing receipts, remove the old receipt
        self.old_receipt = expense.receipts.first if expense.receipts.present?
        self.receipt = user.receipts.find_by(id: params[:receipt_id])
      end
    end

    if expense.present?
      pocket_id = self.params&.dig(:expense, :spent_from_id)
      # Todo - Jugaad - Legacy support for older version of android/iOS where this is not implemented
      if pocket_id.blank? and (params[:expense].present? and params[:expense].has_key?(:reimbursable) and params[:expense].has_key?(:from_cash_on_hand))
        exp_params = params[:expense] || {}
        reimbursable = StringUtils.to_bool exp_params[:reimbursable]
        from_cash_on_hand = StringUtils.to_bool exp_params[:from_cash_on_hand]
        if reimbursable
          pocket_id = expense.user.user_pockets.reimbursement_pocket_only&.first&.id
        elsif from_cash_on_hand
          pocket_id = expense.user.user_pockets.cash_pockets_only&.first&.id
        elsif exp_params.key?(:reimbursable) || exp_params.key?(:from_cash_on_hand) # Legacy support for android app -> As android only sends the key which has been updated
          pocket_id = expense.user.user_pockets.paid_by_company_pocket_only&.first&.id
        end
        if pocket_id.blank?
          pocket_id = expense.user.user_pockets.cash_pockets_only.first&.id
        end
      end
      self.cash_pocket = expense.user.user_pockets.non_bank_card_transfer_pockets.find_by(id: pocket_id) || expense&.spent_from
      # Jugaad End
      if pocket_id.present?
        self.cash_pocket = expense.user.user_pockets.non_bank_card_transfer_pockets.find_by(id: pocket_id) || expense&.spent_from
        self.updated_expense_params[:spent_from_id] = self.cash_pocket&.id
      end
    end
  end

  def authorize
    unless expense
      raise_unauthorized_exception
    end
    # i.e. if an employee is editing an expense
    if personal_view? and expense.user_id != user.id
      raise_unauthorized_exception
    end
  end

  def validate
    if expense.report_id and personal_view?
      unless expense.report.editable?
        messages[:error] << 'Expense cannot be edited at this stage'
        return
      end
    end

    # if self.updated_expense_params[:spent_from_id].blank?
    #   add_message :error, 'Please select the Spend Account'
    #   return
    # end

    if self.updated_expense_params[:spent_from_id].present? && self.cash_pocket.blank?
      add_message :error, 'Error in Spend Account'
      return
    end

    # checking if there is enough cash on hand to mark this expense as from cash on hand
    check_coh_availability_update(self.cash_pocket, updated_expense_params)

    # ensuring a particular expense cannot be both reimbursable and from cash on hand
    check_coh_reimbursable_exclusivity_update(updated_expense_params)
  end

  def pre_process
    # if the expense is from cash on hand, mark it as non-reimbursable by default
    if StringUtils.to_bool(updated_expense_params[:from_cash_on_hand]) || updated_expense_params[:spent_from_id].present?
      updated_expense_params[:reimbursable] = false
    end

    # conversely if the expense is marked as reimbursable, automatically make it not from any cash pocket
    if StringUtils.to_bool(updated_expense_params[:reimbursable])
      updated_expense_params[:spent_from_id] = nil
    end
    updated_expense_params[:modified_by_id] = actual_current_user.id if actual_current_user.present?
  end

  def process
    # Set custom fields
    custom_fields = {custom_fields: params[:custom_fields]}
    custom_fields[:save] = false
    # custom_fields[:reset_fields] = true
    set_fields = CustomField::SetFields.(self.expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    # validating the custom fields here
    # todo - in android workflow the dependent custom fields is breaking, so need to prevent validation in the app
    unless RequestStore.store[:request]&.path&.include?('/mobile/v0')
      valid = CustomField::Validate.(self.expense.manual_expense)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return false
      end
    end

    if expense.update(updated_expense_params)
      if self.destroy_receipts
        expense.receipts.each do |receipt|
          if receipt
            receipt.parent = nil
            receipt.save
          end
        end
      end
      if receipt
        receipt.parent = expense
        if receipt.save
          if old_receipt.present?
            old_receipt.parent = nil
            old_receipt.save
          end
        end
      end
    else
      add_message :error, self.expense.errors.full_messages
    end
  end

  def post_process
    # add comment in report if expense is added within report
    Reports::Expenses::UpdateComment.(self.user, updated_expense: self.expense, updated_attributes: editable_attrs)

    if expense.date == DateUtils.local_date
      if expense.report.present? && expense.amount.currency_id != expense.report.base_currency_id
        expense.destroy_other_currencies
      end
    else
      expense.update_other_currencies
    end

    Expense::Manual::Duplicate::ProcessDuplicate.(self.user, expense: self.expense)

    # marking the expense as non-transcribed after the first edit
    if expense.transcribed
      expense.update(transcribed: false)
      expense.system_messages.destroy_all
      if expense.receipts.present?
        expense.receipts.each do |receipt|
          receipt.update(to_be_transcribed: false)
        end
      end
    end

    # checking if the expense has any receipts, and marking them all as no need to be transcribed
    if expense.receipts.present?
      expense.receipts.update_all(to_be_transcribed: false)
    end

    # check if this expense's amount allows for it to be marked against COH
    # and if it is or is not, update the flag for this expense accordingly
    if expense.amount.present? && expense.from_cash_on_hand
      pocket = expense.spent_from
      if pocket.cash_pocket?
        pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
        if pocket_adapter.balance(display_balance: true) >= expense.amount_value
          expense.update(cash_on_hand_blocked: true)
        end
        if pocket_adapter.balance(display_balance: true) < 0
          expense.update(cash_on_hand_blocked: false)
        end
      elsif pocket.credit_card_pocket?
        expense.update(cash_on_hand_blocked: true)
      end
    end

    add_message :success, 'Expense updated'
  end

  private

  def define_editable_attributes
    self.editable_attrs = {note: expense.note,
                           date: expense.date,
                           merchant_name: expense.merchant_name,
                           amount_value: expense.amount_value,
                           category_name: expense.category_name,
                           receipt: expense.receipts.count,
                           from_cash_on_hand: expense.from_cash_on_hand
    }
  end

end
# operation that creates an expense from the manually transcribed data of the receipt
# params:
# expense: { amount_attributes: { value: ""},
#            note: "",
#            category_id: "",
#            date: "",
#            manual_expense_attributes: {merchant: ""}
# receipt_id: id of the receipt being transcribed
# }

class Transcriber::Expenses::Create < Transcriber::Expenses::Base

  attr_accessor :expense_params, :receipt, :selected_user, :expense, :illegible, :company

  def pre_validate
    super()
    if params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    self.expense_params = manual_expense_params
    self.receipt = Receipt.find_by(id: params[:receipt_id])
    self.selected_user = receipt.user if receipt
    self.illegible = params[:illegible]
    self.company = self.selected_user.company
  end

  def validate
    unless receipt
      add_message :error, "Receipt not found"
      return
    end
    unless selected_user
      add_message :error, "Receipt owner not found"
      return
    end
    unless selected_user.company.ocr_enabled?
      add_message :error, "OCR not enabled for this company"
      return
    end
    if receipt.parent.present?
      add_message :error, "This receipt is already associated with an expense"
    end
  end

  def authorize

  end

  def pre_process
    set_system_messages
    expense_params[:expense_type_id] = ExpenseType.manual_expense_id
    expense_params[:expense_status_id] = ExpenseStatus.unreported_id
    # expense_params[:amount_attributes][:currency_id] = Currency.first.id
    expense_params[:transcribed] = true
  end

  def process
    if illegible
      receipt.update(to_be_transcribed: false)
      system_message = receipt.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error), content: "Expense was not automatically generated because receipt was illegible")
      unless system_message.save
        add_message :error, system_message.errors.full_messages
      end
    else
      self.expense = selected_user.expenses.build(expense_params)
      set_pocket
      return unless validate_custom_fields
      if expense.save
        receipt.update(parent: expense)
      else
        messages[:error] = expense.errors.full_messages
      end
    end
  end

  def post_process
    if illegible
      add_message :success, "Receipt marked as illegible"
    else
      expense.update(transcribed: true)
      add_message :success, "Receipt transcribed"
    end
  end

  private

  def set_system_messages
    expense_params[:system_messages_attributes] = []
    illegible_attributes = []
    if expense_params[:amount_attributes][:value] == "--"
      illegible_attributes << "Amount"
      expense_params[:amount_attributes][:value] = 0
    end
    if expense_params[:manual_expense_attributes][:merchant] == "--"
      illegible_attributes << "Merchant"
    end
    if expense_params[:date] == "--"
      illegible_attributes << "Date"
      expense_params[:date] = DateUtils.local_date # setting the date as today by default
    end
    unless illegible_attributes.empty?
      expense_params[:system_messages_attributes] << {
          content: "#{illegible_attributes.to_sentence} #{illegible_attributes.size == 1 ? 'is' : 'are'} illegible",
          system_message_type_id: SystemMessageType.id_for(:error)
      }
    end
    expense_params.permit!
  end

  def validate_custom_fields
    if self.expense.valid?
      set_fields = set_custom_fields false
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return false
      end
      # valid = CustomField::Validate.(self.expense.manual_expense)
      # unless valid.success?
      #   add_message :error, valid.messages[:error]
      #   return false
      # end
      # self.expense.manual_expense.custom_fields.destroy_all
    else
      add_message :error, self.expense.errors.full_messages
      return false
    end
    true
  end

  def set_custom_fields(save)
    custom_fields = {custom_fields: (params[:custom_fields] or params[:expense][:custom_fields])}
    custom_fields[:user] = selected_user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(self.expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
  end

  def set_pocket
    if expense.amount.present? and expense.amount.value > 0
      amount = expense.amount.value || 0
      coh_pocket = selected_user.user_pockets.cash_pockets_only&.first
      coh_amount = 0
      if coh_pocket.present?
        adapter = AccountManager::CashPockets::CashPocketsAdapter.new(coh_pocket)
        coh_amount = adapter.balance(display_balance: true)
      end
      reimbursement_pocket = selected_user.user_pockets.reimbursement_pocket_only&.first
      if coh_pocket.present? and reimbursement_pocket.present?
        if coh_amount >= amount
          expense.spent_from = coh_pocket
        else
          expense.spent_from = reimbursement_pocket
        end
      elsif reimbursement_pocket.present? and coh_pocket.blank?
        expense.spent_from = reimbursement_pocket
      elsif reimbursement_pocket.blank? and coh_pocket.present?
        expense.spent_from = coh_pocket
      else
          # Blank blank
      end
    end
  end
end

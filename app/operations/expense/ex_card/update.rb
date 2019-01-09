# updating the expense from user's expenses view.
# The only editable fields are: editable_merchant, note, category_id, and receipts

class Expense::ExCard::Update < Expense::ExCard::Base
  attr_accessor :updated_expense_params, :editable_attrs, :receipt, :old_receipt, :destroy_receipts

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "Parameters not present."
    end
    if params[:expense_id].blank? and params[:id].blank?
      messages[:error] << "Expense ID missing!"
    end
  end


  def init
    super
    define_editable_attributes if expense
    # id = (params[:expense_id] or params[:id])
    # self.expense = user.expenses.find_by(id: id)
    self.updated_expense_params = update_card_expense_params
    if updated_expense_params[:receipts_attributes] == [nil] or updated_expense_params[:receipts_attributes] == [""]
      # if the receipts attributes is passed as [""], the receipt attached to this expense gets disassociated
      # todo - check if the api fails because of this
      if updated_expense_params[:receipts_attributes] == [""]
        self.destroy_receipts = true
      end
      # end
      updated_expense_params.delete(:receipts_attributes)
    end
    if expense
      if expense.receipts.present? and updated_expense_params[:receipts_attributes].present?
        self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
      end
      if params[:receipt_id]
        # If a new receipt is attached from existing receipts, remove the old receipt
        self.old_receipt = expense.receipts.first if expense.receipts.present?
        self.receipt = user.receipts.find_by(id: params[:receipt_id])
      end
      # adding the associated card expense id for the card expense
      self.updated_expense_params[:card_expense_attributes][:id] = expense.card_expense.id if self.updated_expense_params[:card_expense_attributes].present?
    end
  end


  def validate
    if expense.report_id and personal_view?
      unless expense.report.editable?
        messages[:error] << "Expense cannot be edited at this stage"
        return
      end
    end

    if StringUtils.to_bool params.dig(:expense, :reimbursable)
      add_message :error, "Card expenses are non-reimbursable by default"
      return
    end
  end

  def authorize
    unless expense
      raise_unauthorized_exception
    end
    if personal_view? and expense.user_id != user.id
      raise_unauthorized_exception
    end
  end

  def pre_process
    updated_expense_params[:modified_by_id] = actual_current_user.id if actual_current_user.present?
  end

  def process
    custom_fields = {custom_fields: params&.dig(:custom_fields)}
    custom_fields[:save] = false
    set_fields = CustomField::SetFields.(self.expense.card_expense, FieldParentType.id_for(:card_expense), custom_fields)
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
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
      messages[:error] = self.expense.errors.full_messages
    end
  end

  def post_process
    # add report comment
    Report::Expenses::UpdateComment.(self.user, updated_expense: self.expense, updated_attributes: editable_attrs)

    # if the new category is personal, mark the expense as personal
    if expense.category_name == 'Personal'
      Expense::Personal::Mark.(user, {expense_id: expense.id})
    end
    ###############################################################

    messages[:success] << 'Expense updated'
  end

  private

  def define_editable_attributes
    self.editable_attrs = {note: expense.note,
                           merchant_name: expense.merchant_name,
                           category_name: expense.category_name,
                           receipt: expense.receipts.count
    }
  end

end

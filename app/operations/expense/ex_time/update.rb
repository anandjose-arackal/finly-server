class Expense::ExTime::Update < Expense::ExTime::Base

  attr_accessor :updated_expense_params
  attr_accessor :editable_attrs, :receipt, :old_receipt

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << "Parameters or user not found"
      return false
    end
    if params[:expense_id].nil? and params[:id].blank?
      messages[:error] << "Expense ID missing!"
      return false
    end
    time_value = params[:expense][:time_expense_attributes][:time_object_attributes][:value].to_d rescue nil
    if time_value.present? and time_value <= 0
      messages[:error] << 'time cannot be less than or equal to 0'
    end
  end

  def init
    super
    # saving previous expense attributes before updation
    define_editable_attributes if expense
    # setting up the expense params for updation
    self.updated_expense_params = time_expense_params
    if updated_expense_params[:receipts_attributes] == [nil] or updated_expense_params[:receipts_attributes] == [""]
      # if the receipts attributes is passed as [""], the receipt attached to this expense gets disassociated
      if updated_expense_params[:receipts_attributes] == [""]
        receipt = expense.receipts.first
        if receipt
          receipt.parent = nil
          receipt.save
        end
      end
      updated_expense_params.delete(:receipts_attributes)
    end
    if expense
      if self.updated_expense_params[:time_expense_attributes].present? and self.updated_expense_params[:time_expense_attributes][:time_object_attributes].present? and
          expense.time_expense.present?
        self.updated_expense_params[:time_expense_attributes][:id] = expense.time_expense.id
      end
      if self.updated_expense_params[:time_expense_attributes][:time_object_attributes].present? and self.updated_expense_params[:time_expense_attributes][:time_object_attributes][:value].present? and
          expense.time_expense.time_object_id.present?
        self.updated_expense_params[:time_expense_attributes][:time_object_attributes][:id] = expense.time_expense.time_object.id
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
    if receipt
      unless receipt.user_id == user.id
        add_message :error, "You do not own this receipt"
      end
    end
  end

  def process

    # Set custom fields
    custom_fields = {custom_fields: params[:custom_fields]}
    custom_fields[:save] = false
    set_fields = CustomField::SetFields.(self.expense.time_expense, FieldParentType.id_for(:time_expense), custom_fields)
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.expense.time_expense)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end

    if expense.update(updated_expense_params)
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
    Report::Expenses::UpdateComment.(self.user, updated_expense: self.expense, updated_attributes: editable_attrs)

    # if the expense has an associated amount, update the amount
    if expense.amount.present? && expense.report.present?
      amount = expense.amount
      amount.update(value: expense.calculate_amount_value(expense.report.policy))
    end

    # if the new category is personal, mark the expense as personal
    if expense.category_name == 'Personal'
      Expense::Personal::Mark.(user, {expense_id: expense.id})
    end
    ###############################################################

    unless expense.date == DateUtils.local_date
      expense.update_other_currencies
    end

    add_message :success, 'Expense updated'
  end

  private

  def define_editable_attributes
    self.editable_attrs = {note: expense.note,
                           date: expense.date,
                           time_value: expense.time_value,
                           category_name: expense.category_name,
                           receipt: expense.receipts.count
                          }
  end

end
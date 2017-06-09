# action to update an expense.
# params:
# expense_id, or id : the id of the expense that us going to be edited.
#

class Expense::Manual::Update < Expense::Manual::Base
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
    amount_value = params[:expense][:amount_attributes][:value].to_d rescue nil
    if amount_value.present? and amount_value <= 0
      messages[:error] << 'Amount cannot be less than or equal to 0'
    end
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
        receipt = expense.receipts.first
        if receipt
          receipt.parent = nil
          receipt.save
        end
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
  end

  def process
    # Set custom fields
    custom_fields = {custom_fields: params[:custom_fields]}
    custom_fields[:save] = false
    set_fields = CustomField::SetFields.(self.expense.manual_expense, FieldParentType.id_for(:manual_expense), custom_fields)
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.expense.manual_expense)
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

    Expense::Manual::ProcessDuplicate.(self.user, expense: self.expense)

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

    # if the new category is personal, mark the expense as personal
    if expense.category_name == 'Personal'
      Expense::Personal::Mark.(user, {expense_id: expense.id})
    end
    ###############################################################

    if expense.date == DateUtils.local_date
      if expense.report.present? && expense.amount.currency_id != expense.report.base_currency_id
        expense.destroy_other_currencies
      end
    else
      expense.update_other_currencies
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
                           receipt: expense.receipts.count}
  end

end

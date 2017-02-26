# updating the expense from user's expenses view.
# The only editable fields are: editable_merchant, note, category_id, and receipts

class Expense::ExCard::Update < Expense::ExCard::Base
  attr_accessor :updated_expense_params, :editable_attrs, :receipt, :old_receipt

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
        receipt = expense.receipts.first
        if receipt
          receipt.parent = nil
          receipt.save
        end
      end
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
      end
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


  def process
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
      messages[:error] = self.expense.errors.full_messages
    end
  end

  def post_process
    # add report comment
    Report::Expenses::UpdateComment.(self.user, updated_expense: self.expense, updated_attributes: editable_attrs)

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

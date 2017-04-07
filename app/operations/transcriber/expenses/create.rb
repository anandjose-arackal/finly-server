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

  attr_accessor :expense_params, :receipt, :selected_user, :expense


  def init
    self.expense_params = manual_expense_params
    self.receipt = Receipt.find_by(id: params[:receipt_id])
    self.selected_user = receipt.user if receipt
  end

  def validate
    unless receipt
      add_message :error, "Receipt not found"
      return
    end
    unless selected_user.company.ocr_enabled?
      add_message :error, "OCR not enabled for this company"
    end
  end

  def authorize
    unless user.company_id == Company.find_by(name: "Transcriber").id
      raise_unauthorized_exception
    end
  end

  def pre_process
    expense_params[:expense_type_id] = ExpenseType.manual_expense_id
    expense_params[:expense_status_id] = ExpenseStatus.unreported_id
    expense_params[:amount_attributes][:currency_id] = Currency.first.id
  end

  def process
    self.expense = selected_user.expenses.build(expense_params)
    if expense.save
      receipt.update(parent: expense)
    else
      messages[:error] = expense.errors.full_messages
    end
  end

  def post_process
    expense.update(transcribed: true)
    add_message :success, "Receipt transcribed"
  end

end
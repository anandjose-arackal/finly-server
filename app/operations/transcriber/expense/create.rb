# operation that creates an expense from the manually transcribed data of the receipt
# params:
# expense: { amount_attributes: { value: ""},
#            note: "",
#            category_id: "",
#            date: "",
#            manual_expense_attributes: {merchant: ""}
# receipt_id: id of the receipt being transcribed
# }

class Transcriber::Expense::Create < Transcriber::Expense::Base

  attr_accessor :expense_params

  def pre_validate

  end

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
    unless selected_user.company.ocr_enabled
      add_message :error, "OCR not enabled for this company"
    end
  end

  def authorize
    unless user.company_id == Company.find_by(name: "Transcriber")
      raise_unauthorized_exception
    end
  end

  def process
    expense = selected_user.expenses.build(expense_params)
    if expense.save
      receipt.update(parent: expense)
    else
      add_message :error, expense.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Receipt transcribed"
  end

end
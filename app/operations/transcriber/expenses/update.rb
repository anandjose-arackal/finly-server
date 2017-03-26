class Transcriber::Expenses::Update < Transcriber::Expenses::Base

  attr_accessor :expense_params, :receipt, :selected_user, :expense

  def pre_validate

  end

  def init
    self.expense_params = manual_expense_params
    self.receipt = Receipt.find_by(id: params[:receipt_id])
    self.selected_user = receipt.user if receipt
    self.expense = Expense.find_by(params[:id])
  end

  def validate
    unless receipt
      add_message :error, "Receipt not found"
      return
    end
    unless selected_user.company.ocr_enabled?
      add_message :error, "OCR not enabled for this company"
      return
    end
    unless expense
      add_message :error, "Expense not found"
    end
  end

  def authorize
    unless user.company_id == Company.find_by(name: "Transcriber") || user.email == 'admin@finlytest.io'
      raise_unauthorized_exception
    end
  end

  def process
    if expense.save
      receipt.update(parent: expense, transcribed: true)
    else
      messages[:error] = expense.errors.full_messages
    end
  end

  def post_process
    expense.update(transcribed: true)
    add_message :success, "Receipt transcribed"
  end
end

class Transcriber::Expenses::Update < Transcriber::Expenses::Base

  attr_accessor :expense_params, :receipt, :selected_user, :expense


  def init
    self.expense_params = manual_expense_params
    self.expense = Expense.find_by(id: params[:id])
    self.selected_user = expense.user if expense
  end

  def validate
    unless selected_user.company.ocr_enabled?
      add_message :error, "OCR not enabled for this company"
      return
    end
    unless expense
      add_message :error, "Expense not found"
    end
  end

  def authorize
    unless user.company_id == Company.find_by(name: "Transcriber").id
      raise_unauthorized_exception
    end
  end

  def pre_process
    expense_params[:amount_attributes][:currency_id] = Currency.first.id
  end

  def process
    if expense.update(expense_params)
    else
      messages[:error] = expense.errors.full_messages
    end
  end

  def post_process
    expense.update(transcribed: true)
    add_message :success, "Receipt transcribed"
  end
end

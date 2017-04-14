class Transcriber::Expenses::Update < Transcriber::Expenses::Base

  attr_accessor :expense_params, :receipt, :selected_user, :expense

  def pre_validate
    super()
    if params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    self.expense_params = manual_expense_params
    self.expense = Expense.find_by(id: params[:id])
    self.selected_user = expense.user if expense
  end

  def validate
    unless selected_user.present?
      add_message :error, "Expense owner not found"
      return
    end
    unless selected_user.company.ocr_enabled?
      add_message :error, "OCR not enabled for this company"
      return
    end
    unless expense
      add_message :error, "Expense not found"
      return
    end
    unless expense.transcribed
      add_message :error, "This expense cannot be edited"
    end
  end

  def authorize

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

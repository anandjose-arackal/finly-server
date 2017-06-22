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

  attr_accessor :expense_params, :receipt, :selected_user, :expense, :illegible

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
    expense_params[:amount_attributes][:currency_id] = Currency.first.id
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
    if expense_params[:amount_attributes][:value] == "--"
      expense_params[:system_messages_attributes] << {
        content: "Amount is illegible",
        system_message_type_id: SystemMessageType.id_for(:error)
      }
      expense_params[:amount_attributes][:value] = 0
    end
    if expense_params[:manual_expense_attributes][:merchant] == "--"
      expense_params[:system_messages_attributes] << {
        content: "Merchant is illegible",
        system_message_type_id: SystemMessageType.id_for(:error)
      }
    end
    if expense_params[:date] == "--"
      expense_params[:system_messages_attributes] << {
        content: "Date is illegible",
        system_message_type_id: SystemMessageType.id_for(:error)
      }
      expense_params[:date] = DateUtils.local_date # setting the date as today by default
    end
    expense_params.permit!
  end

end

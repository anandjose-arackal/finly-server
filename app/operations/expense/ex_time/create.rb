# operation to create a time expense
# parameters :
# expense: { time_expense_attributes: { time_object_attributes: { value:  of the time
#                                                                }
#                                         }
#            note: "Sample note"
#            category_id: 2
#            date: "25-01-17"
#            expense_type_id: 4
#            expense_status_id: 4
#          }
# type: '4' for time expense
# }

class Expense::ExTime::Create < Expense::ExTime::Base

  attr_accessor :expense_params, :receipt

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters passed"
    end
    if params[:expense].blank?
      messages[:error] << 'You have not provided any details to create an expense'
      return
    end
    time_value = params[:expense][:time_expense_attributes][:time_object_attributes][:value].to_d rescue nil
    if time_value.present? and time_value <= 0
      messages[:error] << 'Time cannot be less than or equal to 0'
    end
  end

  def init
    self.expense_params = time_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.time_expense_id
    if params[:receipt_id].present?
      self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    end
    if expense_params[:receipts_attributes] == [nil]
      expense_params.delete(:receipts_attributes)
    end
  end

  def validate
    if expense_params[:receipt_id].present? and receipt.blank?
      messages[:error] << 'Receipt not found'
      return false
    end

    # checking if time expense has been enabled for the user at the company or policy level
    unless user.time_expense_enabled?
      add_message :error, "Time expense creation is not enabled"
      return false
    end

    # checking if the report is editable for personal view
    if personal_view? and expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      unless report.editable?
        messages[:error] << "Expense cannot be added to the report in this state"
      end
    end
  end

  def process
    self.expense = user.expenses.build(expense_params)
    if self.expense.save
      # Attach an existing receipt to the expense
      if self.receipt.present?
        self.receipt.parent = expense
        self.receipt.save
      end
    else
      messages[:error] = self.expense.errors.full_messages
    end
  end

  def post_process
    # add comment in report if expense is added within report
    if self.expense.report_id.present? and self.expense.report.retracted?
      comment = self.expense.report.comments.build report: self.expense.report, user: user,
                                                   report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
      unless comment.save
        messages[:error] = comment.errors.full_messages
      end
    end
    # if the expense is part of a report, calculate the associated amount
    if expense_params[:report_id].present?
      report = user.reports.find_by(id: expense_params[:report_id])
      amount = expense.amount
      if amount.nil?
        amount_params = {value: expense.calculate_amount_value(report.policy), currency_id: Currency.first.id}
        amount = Amount.create(amount_params)
      else
        amount.update(value: expense.calculate_amount_value(report.policy))
      end
      expense.update_attributes(amount_id: amount.id)
    end

    messages[:success] << 'Expense created'
  end
end
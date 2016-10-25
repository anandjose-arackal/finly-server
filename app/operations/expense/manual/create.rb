# Class to create an expense
# format of parameters,

class Expense::Manual::Create < Expense::Manual::Base
  attr_accessor :expense_params, :receipt

  def pre_validate
    super
    if params.blank?
      messages[:error] << 'Parameters not present.'
    end
    if params[:expense].blank?
      messages[:error] << 'You have not provided any details to create an expense'
      return
    end
    if params[:expense][:amount].to_d < 0
      messages[:error] << "Amount can't be negative."
    end
  end

  def init
    self.expense_params = manual_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.manual_expense_id
    if params[:receipt_id].present?
      self.receipt = user.receipts.with_id(params[:receipt_id]).first rescue nil
    end
    if expense_params[:receipts_attributes] == [nil]
      expense_params.delete(:receipts_attributes)
    end
  end

  def validate
    # can't think of anything for now
    if expense_params[:receipt_id].present? and receipt.blank?
      messages[:error] << 'Receipt not found'
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
      comment = self.expense.report.comments.build report: self.expense.report, user: user, report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense: expense
      unless comment.save
        messages[:error] = comment.errors.full_messages
      end
    end
    messages[:success] << 'Expense created'
  end

  # def success
  #   Expense::Manual::Create::CreatePresenter.new(expense)
  # end

end
# Class to create an expense
# format of parameters,

class Expense::Manual::Create < Expense::Manual::Base
  attr_accessor :expense_params

  def pre_validate
    super
    if params.blank?
      errors << 'Parameters not present.'
    end
    if params[:expense].blank?
      errors << 'You have not provided any details to create an expense'
      return
    end
    if params[:expense][:amount].to_i < 0
      errors << "Amount can't be negative."
    end
  end

  def init
    self.expense_params = manual_expense_params
    self.expense_params[:expense_type_id] = ExpenseType.manual_expense_id
  end

  def validate
    # can't think of anything for now
  end

  def process
    self.expense = user.expenses.build(expense_params)
    unless self.expense.save
      errors << self.expense.errors.full_messages
    end
  end

  def post_process
    # add comment in report if expense is added within report
    if self.expense.report_id.present?
      # this will be changed to the respective operation when it's done
      ReportService.new(user: user, report: expense.report).expense_created_in_report(expense) if expense.report_id.present? and user.present?
    end
  end

  def success
    Expense::Manual::Create::CreatePresenter.new(expense)
  end

end
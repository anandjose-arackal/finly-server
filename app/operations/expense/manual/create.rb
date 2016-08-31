# Class to create an expense
# format of parameters,

class Expense::Manual::Create < Expense::Base

  attr_accessor :expense_params

  class Expense::Manual::Create::CreatePresenter < Expense::Base::ExpensePresenter
    attr_accessor :expense

    def initialize(expense)
      self.expense = expense
    end
  end

  def pre_validate
    if params.blank? or user.blank?
      errors << "Parameters or user not present."
    end
    if params[:expense][:amount].to_i < 0
      errors << "Amount can't be negative."
    end
  end

  def init
    self.expense_params = manual_expense_params
    expense_params.delete(:receipt)
  end

  def validate
    # can't think of anything for now
  end

  def process
    self.expense = user.expenses.build(expense_params)
    unless self.expense.save
      errors << self.expense.errors.full_messages
      return false
    end
  end

  def post_process
    # add comment in report if expense is added within report
    if self.expense.report_id.present?
      # this will be changed to the respective operation when it's done
      ReportService.new(user: user, report: expense.report).expense_created_in_report(expense) if expense.report_id.present? and user.present?
    end
  end

  # the presenter here returns the created expense
  def retrieve
    if is_success?
      created_expense = Expense::Manual::Create::CreatePresenter.new(expense)
      return created_expense
    else
      return false
    end
  end
end
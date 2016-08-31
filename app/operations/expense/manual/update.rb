class Expense::Manual::Update < Expense::Base

  attr_accessor :old_expense, :updated_expense_params

  class Expense::Manual::Create::UpdatePresenter < Expense::Base::ExpensePresenter
    attr_accessor :expense

    def initialize(expense)
      self.expense = expense
    end
  end

  def pre_validate
    if params.blank? or user.blank?
      errors << "Parameters or user not present."
    end
    if params[:expense_id].nil?
      errors << "Expense ID missing!"
    end
    if params[:expense][:amount] < 0
      errors << "Amount can't be negative."
    end
  end


  def init
    self.expense = self.old_expense = user.expenses.find_by_id(params[:expense_id])
    # setting up the expense params for updation
    self.updated_expense_params = manual_expense_params
    self.updated_expense_params[:amount_attributes][:id] = expense.amount.id if expense
    self.updated_expense_params[:manual_expense_attributes][:id] = expense.manual_expense.id if expense
    if expense and expense.receipts.present? and updated_expense_params[:receipts_attributes].present?
      self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
    end
  end


  def validate
    unless expense
      errors << "Cannot find expense to edit. "
    end
  end


  def authorize
    unless expense and expense.user_id == user.id
      errors << "You do not own this expense."
    end
  end


  def process
    unless expense.update(updated_expense_params)
      errors << self.expense.errors.full_messages
      return false
    end
    success
  end

  def post_process
    # add comment in report if expense is added within report
    if self.expense.report_id.present?
      # this will be changed to the respective operation when it's done
      ReportService.new(user: user, report: expense.report).expense_updated_in_report(expense, old_expense) if expense.report_id.present? and user.present?
    end

    # send mailer indicating updation of expense
  end

  def retrieve
    if is_success?
      update_presenter = Expense::Manual::Create::UpdatePresenter.new(receipt)
      return update_presenter
    else
      return false
    end
  end

end
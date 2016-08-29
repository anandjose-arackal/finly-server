# action to add exisitng expenses to a report.
# params:
# report_id: id of the report to which expenses need to be added
# expense_ids : array of ids of expenses that need to be added to the report.

class Report::Expenses::Add < Report::Base

  attr_accessor :expenses, :retracted

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end

    if params[:expense_ids].blank?
      errors << "No expenses to add."
    end
  end

  def init
    self.report = Report.find_by(id: params[:report_id])
    self.expenses = user.expenses.where(id: params[:expense_ids])
    # if the report is in retracted stage, comments need to be added
    self.retracted = report.retracted?
  end

  def validate
    # checking state of the report
    unless report.open? or report.retracted?
      errors << 'Cannot add expenses to report unless report is in open or retracted state'
      return false
    end
  end

  def authorize
    unless report
      errors << "Report not found."
      return false
    end

    # checking if the expense ids correspond to actual expenses
    unless expenses
      errors << "No expenses found to add to the report."
      return false
    end

    unless report.user_id == user.id
      errors << "You cannot add expenses to this report."
    end
  end

  def process
    expenses.each do |expense|
      unless expense.update_attributes(report_id: report.id, expense_status_id: ExpenseStatus.unsubmitted_id, manager_memo: nil, rejecting_manager: nil)
        errors << expense.errors.full_messages
      end
    end
  end

  def post_process
    if is_success?
      if retracted
        expenses.each do |expense|
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.expense_add_id, expense_id: expense.id
          comment.save
        end
      end
    end
  end
end
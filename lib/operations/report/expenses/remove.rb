# removing expenses. Almost exactly the same as adding expenses in terms of flow.
# params:
# report_id: id of the report that the action will be performed on
# expense_ids: ids of the expenses that are to be removed.

class Report::Expenses::Remove < Report::Base

  attr_accessor :expenses, :retracted

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end

    if params[:expense_ids].blank? and params[:expense_id].blank?
      messages[:error] << "No expenses to add."
    end
  end

  def init
    self.report = Report.find_by(id: params[:report_id])
    # extracting the expenses from the report itself
    ids = (params[:expense_ids] or params[:expense_id])
    # Split if IDS are sent as one comma delimited string
    ids= ids.split(',')
    self.expenses = report.expenses.where(id: ids)
    # if the report is in retracted stage, comments need to be added
    self.retracted = report.retracted?
  end

  def validate

    # checking if the expense ids correspond to actual expenses
    unless expenses
      messages[:error] << "No expenses found to be removed from the report."
      return false
    end

    # checking state of the report
    unless report.open? or report.retracted?
      messages[:error] << 'Cannot remove expenses from report unless report is in open or retracted state'
      return false
    end
  end

  def authorize
    unless report
      raise_unauthorized_exception
      return false
    end
    unless report.user_id == user.id
      messages[:error] << "You cannot add expenses to this report."
    end
  end

  def process
    expenses.each do |expense|
      unless expense.update_attributes(report_id: nil, expense_status_id: ExpenseStatus.unreported_id, manager_memo: nil, rejecting_manager: nil)
        messages[:error] << expense.errors.full_messages
      end
    end
  end

  def post_process
    if success?
      if retracted
        expenses.each do |expense|
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.expense_remove_id, expense_id: expense.id
          comment.save
        end
      end
    end
  end
end

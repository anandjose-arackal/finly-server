# action to add exisitng expenses to a report.
# params:
# report_id: id of the report to which expenses need to be added
# expense_ids : array of ids of expenses that need to be added to the report.

class Report::Expenses::Add < Report::Base

  attr_accessor :expenses

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
    index_operation = Report::Index.new(self.user, self.params)
    reports_presenter = index_operation.run
    unless index_operation.success?
      self.messages = index_operation.errors
      return false
    end
    self.report = reports_presenter.reports.find_by(id: params[:report_id]) rescue nil
    ids = (params[:expense_ids] or params[:expense_id])
    # Split if IDS are sent as one comma delimited string
    ids= ids.split(',')
    self.expenses = user.expenses.where(id: ids)
  end

  def authorize
    unless report
      messages[:error] << "Report not found."
      return false
    end

    # checking if the expense ids correspond to actual expenses
    unless expenses
      messages[:error] << "No expenses found to add to the report."
      return false
    end

    unless report.user_id == user.id
      messages[:error] << "You cannot add expenses to this report."
    end
  end

  def validate
    # checking state of the report
    unless report.open? or report.retracted?
      messages[:error] << 'Cannot add expenses to report unless report is in open or retracted state'
      return false
    end
  end

  def process
    expenses.each do |expense|
      unless expense.update_attributes(report_id: report.id, expense_status_id: ExpenseStatus.unsubmitted_id, manager_memo: nil, rejecting_manager: nil)
        messages[:error] << expense.errors.full_messages
      end
    end
  end

  def post_process
    if success?
      if report.retracted?
        expenses.each do |expense|
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.expense_add_id, expense_id: expense.id
          comment.save
        end
      end
      messages[:success] << "Expenses added."
    end
  end
end
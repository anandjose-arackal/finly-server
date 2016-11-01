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
      add_message :error, 'No user or params passed'
      return
    end

    if params[:expense_ids].blank? and params[:expense_id].blank? and params[:expenses].blank?
      add_message :error, 'No expenses to add'
    end
  end

  def init
    self.report= params[:report]
    return if self.report.blank? and params[:report_id].blank?
    if self.report.blank? and params[:report_id].present?
      index_operation = Report::Index.new(self.user, self.params)
      reports_presenter = index_operation.run
      unless index_operation.success?
        self.messages = index_operation.errors
        return false
      end
      self.report = reports_presenter.reports.with_id(params[:report_id]).first rescue nil
    end
    self.expenses = params[:expenses]
    if params[:expenses].blank? and user.present?
      ids = (params[:expense_ids] or params[:expense_id])
      # Split if IDS are sent as one comma delimited string
      ids= ids.split(',')
      self.expenses = user.expenses.with_id(ids)
    end
  end

  def authorize
    unless report
      add_message :error, 'Report not found'
      return false
    end

    # checking if the expense ids correspond to actual expenses
    unless expenses
      add_message :error, 'No expenses found to add to the report'
      return false
    end

    unless report.user_id == user.id
      add_message :error, 'You cannot add expenses to this report'
    end
  end

  def validate
    # checking state of the report
    unless report.open? or report.retracted? or report.rejected?
      add_message :error, 'Cannot add expenses to report unless report is in open or retracted state'
    end
  end

  def process
    expenses.each do |expense|
      unless expense.update_attributes(report_id: report.id, expense_status_id: ExpenseStatus.unsubmitted_id, manager_memo: nil, rejecting_manager: nil)
        messages[:error] = expense.errors.full_messages
      end
    end
  end

  def post_process
    if success?
      if report.retracted?
        expenses.each do |expense|
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense_id: expense.id
          comment.save
        end
      end
      add_message :success, 'Expenses added'
    end
  end
end
# action to reject expenses within a report.
# params:
# report_id:

class Report::Expenses::Reject < Report::Base
  attr_accessor :expenses

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:expense_ids].blank? and params[:expense_id].blank?
      messages[:error] << 'No expense ids passed'
    end
  end

  def init
    super
    ids = (params[:expense_ids] or params[:expense_id])
    self.expenses = report.expenses.with_id(ids)
  end

  def validate

    # checking if the report is in processing state
    unless report.processing?
      messages[:error] << 'Cannot reject expenses in this state'
    end

    if expenses.blank?
      messages[:error] << 'Expenses to reject not found'
    end
  end

  def authorize
    unless report
      raise_unauthorized_exception
    end

    unless report.controlling_user_id == user.id
      messages[:error] << 'You cannot reject the expenses in this report'
    end
  end

  def process
    expenses.each do |expense|
      unless expense.update_attributes(report_id: nil, expense_status_id: ExpenseStatus.rejected_id,
                                   manager_memo: params[:memo], rejecting_manager: user)
        messages[:error] = expense.errors.full_messages
      end
    end
  end

  def post_process
    if success?
      expenses.each do |expense|
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:expense_reject), expense_id: expense.id, content: params[:memo]
        comment.save
      end
    end
    messages[:success] << 'Expenses rejected!'
  end
end
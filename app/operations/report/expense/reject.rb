# action to reject expenses within a report.
# params:
# report_id:

class Report::Reject < Report::Base

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:expense_ids].blank?
      errors << "No expense ids passed."
    end
  end

  def init
    super()
    self.expenses = report.expenses.where(id: params[:expense_ids])
  end

  def validate
    unless report
      errors << "Report not found!"
    end

    # checking if the report is in processing state
    unless report.processing?
      errors << "Cannot reject expenses in this state."
    end

    if expenses.blank?
      errors << "Expenses to reject not found"
    end

  end

  def authorize
    unless report.controlling_user_id == user.id
      errors << "You cannot reject the expenses in this report."
    end
  end

  def process
    expenses.each do |expense|
      unless expense.update_attributes(report_id: nil, expense_status_id: ExpenseStatus.rejected_id,
                                   manager_memo: params[:memo], rejecting_manager: user)
        errors << expense.errors.full_messages
      end
    end
  end

  def post_process
    if is_success?
      expenses.each do |expense|
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.expense_reject_id, expense_id: expense.id, content: params[:memo]
        comment.save
      end
    end
  end
end
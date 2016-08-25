# action to submit a report.

# params:
# report_id: id of the report that needs to be submitted
# controlling_for_user_id: if a user is submitting a report for someone else

class Report::Submit < Report::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end

  def init
    self.report = user.reports.find_by(id: params[:report_id])
  end

  def validate
    # checking report status
    unless report.can_submit?
      errors << "Cannot submit this report."
      return false
    end
    # checking if the report has expenses
    unless report.expenses.present?
      errors << "Cannot submit an empty report."
    end
  end

  def authorize
    unless report
      raise_unauthorized_exception
      return false
    end
    # if submitting a report for someone else, ensure he has the right to
    if params[:controlling_for_user_id]
      unless report.controlling_for_user_id == user.id
        raise_unauthorized_exception
        return false
      end
    else
      unless report.user_id == user.id
        raise_unauthorized_exception
      end
    end
  end

  def process
    manager = User::Team::Review::NextReviewer.(report)
    # If no manager assigned, auto approve the report
    if manager.blank?
      # call the approve class with the right parameters
      approve_op = Report::Approve.new(user, {report_id: report.id, auto_approve: true})
      unless approve_op.run
        errors << "Couldn't auto-approve report for some reason. Please try again."
        return false
      end
    end
    memo = params[:memo]
    submitted_at = DateTime.now
    if report.update_attributes report_status_id: ReportStatus.processing_id, controlling_user_id: manager.id, controlling_for_user_id: nil, memo: memo, submitted_at: submitted_at
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.submit_id, report_status_id: ReportStatus.processing_id, memo: memo
      track.save
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.submitted_id)
      end
      return true
    end
    errors << report.errors.full_messages
  end

  def post_process
    # adding comment regarding the change in status of this report
    comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_submit_id
    comment.save
  end

end
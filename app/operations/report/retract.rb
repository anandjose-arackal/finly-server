# retracting a report that isn't currently in a processing state
# params:
# report_id: id of the report that is being retracted

class Report::Retract < Report::Base


  def pre_validate
    if user.blank? or params.blank?
      errors << "User or oarams not passed."
    end
  end

  def init
    self.report = user.reports.find_by(id: params[:report_id])
  end

  def validate
    unless report
      errors << "Report not found."
    end

    unless report.processing?
      errors << "Cannot retract report that isn't in processing state."
    end
  end

  def authorize
    unless report.user_id == user.id
      errors << "You don't own this report."
    end
  end

  def process
    if report.update_attributes report_status_id: ReportStatus.retracted_id, controlling_user_id: user.id, controlling_for_user_id: nil, memo: nil, submitted_at: nil
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.retract_id, report_status_id: ReportStatus.retracted_id
      track.save
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.unsubmitted_id)
      end
      return true
    end
    errors << report.errors.full_messages
  end

  def post_process
    if is_success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_retract_id
      comment.save
      # mailers here
    end
  end

end
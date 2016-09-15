# retracting a report that isn't currently in a processing state
# params:
# report_id: id of the report that is being retracted

class Report::Retract < Report::Base

  def authorized_user_types
    :employee
  end

  def pre_validate
    super
    id = (params[:id] or params[:report_id])
    if id.blank?
      messages[:error] << 'Error loading report'
    end
  end

  def init
    id = (params[:id] or params[:report_id])
    self.report = user.reports.with_id(id: id).first rescue nil
  end

  def authorize
    super
    unless report.user_id == user.id
      messages[:error] << "You don't own this report."
    end
  end

  def validate
    unless report.processing?
      messages[:error] << 'Cannot retract report that is not in processing state'
    end
  end

  def process
    if report.update_attributes report_status_id: ReportStatus.retracted_id, controlling_user_id: user.id, controlling_for_user_id: nil, memo: nil, submitted_at: nil
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.retract_id, report_status_id: ReportStatus.retracted_id
      track.save
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.unsubmitted_id)
      end
      return
    end
    messages[:error] << report.errors.full_messages
  end

  def post_process
    if success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_retract_id
      comment.save
      # mailers here
    end
  end

end
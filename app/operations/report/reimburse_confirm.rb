# action that confirms whether a report has been reimbursed

class Report::ReimburseConfirm < Report::Base

  def authorized_user_types
    [:employee]
  end

  def init
    super()
  end

  def validate
    unless report.reimbursed?
      messages[:error] << 'Report cannot be confirm reimbursement as the report is not marked as reimbursed'
    end
  end

  def process
    if report.update_attributes controlling_user: nil, controlling_for_user: nil, report_status_id: ReportStatus.reimbursement_confirmed_id, memo: nil
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reimbursement_confirmed_id, report_status_id: ReportStatus.reimbursement_confirmed_id
      track.save
      return true
    end
    messages[:error] << "Report could not be marked as reimbursed. Please try again."
  end

  def post_process
    if success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reimbursement_confirmed_id
      comment.save
      messages[:success] << "Report reimbursement confirmed."
    end
  end
end
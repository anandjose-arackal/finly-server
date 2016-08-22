# action that approves a report.
# params:
# report_id: id of the report that needs to be approved
# auto_approve : set to true if the report is to be auto-approved. i.e. if there is no reporting manager

class Report::Approve < Report::Base

  attr_accessor :auto_approve

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end

  def init
    self.report = Report.find_by(id: params[:report_id])
    self.auto_approve = params[:auto_approve]
  end

  def validate
    unless report.processing? or params[:auto_approve]
      errors << "Cannot approve this report."
    end
  end

  def authorize
    unless report.controlling_user_id == user.id
      errors << "You cannot approve this report."
      return false
    end
  end

  def process
    manager = User::Team::Review::NextReviewer.(report)
    status = ReportStatus.processing_id
    if auto_approve or manager.blank?
      settlement = SettlementService.new(report.user)
      status = ReportStatus.approved_id
      unless settlement.require_reimbursement?(report)
        status = ReportStatus.closed_id
      end
    end
    manager_id = nil
    manager_id = manager.id if manager.present?
    user_role = user_role_for_report
    if report.update_attributes report_status_id: status, controlling_user_id: manager_id, controlling_for_user_id: nil, memo: nil
      if auto_approve
        track = report.tracks.build action_user: nil, report_tracking_action_id: ReportTrackingAction.auto_approve_id, report_status_id: status
      else
        track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.approve_id, report_status_id: status,
                                    user_report_role_id: user_role
      end
      track.save

      if report.closed?
        track = report.tracks.build action_user: nil, report_tracking_action_id: ReportTrackingAction.closed_id, report_status_id: ReportStatus.closed_id
        track.save
      end
      return true
    end
    errors << report.errors.full_messages
  end

  def post_process
    if is_success?
      if auto_approve
        comment = report.comments.build report_comment_action_id: ReportCommentAction.report_auto_approve_id
      else
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_approve_id
      end
      comment.save

      # recomputing settlement
      unless report.processing?
        SettlementService.new.report_approved report
      end

      # if report is closed, add the relevant comment
      if report.closed?
        # Add comments stating report has been closed as no reimbursements required
        comment = report.comments.build user: nil, report_comment_action_id: ReportCommentAction.report_closed_id
        comment.save
      end
    end
  end

end
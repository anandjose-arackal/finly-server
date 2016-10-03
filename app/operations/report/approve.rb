# action that approves a report.
# params:
# report_id: id of the report that needs to be approved
# auto_approve : optional - set to true if the report is to be auto-approved. i.e. if there is no reporting manager

class Report::Approve < Report::Base
  attr_accessor :auto_approve

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
    if params.blank?
      messages[:error] << 'Error loading configuration'
    end
  end

  def init
    id = (params[:id] or params[:report_id])
    self.report = user.controlling_reports.with_id(id).first rescue nil
    self.auto_approve = params[:auto_approve]
  end

  def authorize
    unless report
      raise_unauthorized_exception
    end
    unless report.controlling_user_id == user.id
      raise_unauthorized_exception
    end
  end

  def validate
    unless report.processing? or params[:auto_approve]
      messages[:error] << 'Cannot approve this report as it is not in processing state'
    end
  end

  def process
    manager = User::Team::Review::NextReviewer.(report)
    status = ReportStatus.processing_id
    if auto_approve or manager.blank?
      status = ReportStatus.approved_id
      unless report.require_reimbursement?
        status = ReportStatus.closed_id
      end
    end
    manager_id = manager.id rescue nil
    user_role = User::Team::Review::UserRole.(user, self.report)
    if report.update_attributes report_status_id: status, controlling_user_id: manager_id, controlling_for_user_id: nil, memo: nil, submitted_at: DateTime.now
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
    messages[:error] = report.errors.full_messages
  end

  def post_process
    if success?
      if auto_approve
        comment = report.comments.build report_comment_action_id: ReportCommentAction.id_for(:report_auto_approve)
      else
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_approve)
      end
      comment.save

      # recomputing settlement and marking the report as accounted
      unless report.processing?
        Settlement::Report::Approved.(user, report: report)
        report.reload
      end
      # if report is closed, add the relevant comment
      if report.closed?
        # Add comments stating report has been closed as no reimbursements required
        comment = report.comments.build user: nil, report_comment_action_id: ReportCommentAction.id_for(:report_closed)
        comment.save
      end
      # Send notifications
      Event::EReport::Approve.(self.user, report: self.report)

      messages[:success] << 'Report approved!'
    end
  end

end
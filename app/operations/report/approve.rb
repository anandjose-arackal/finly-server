# action that approves a report.
# params:
# report_id: id of the report that needs to be approved
# auto_approve : optional - set to true if the report is to be auto-approved. i.e. if there is no reporting manager

class Report::Approve < Report::Base
  attr_accessor :auto_approve

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve])
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
    presenter = User::Team::Review::NextReviewer.(report)
    manager = presenter.user
    to_user_role_id = presenter.role_id
    status = ReportStatus.processing_id
    if auto_approve or manager.blank?
      status = ReportStatus.approved_id
      unless report.require_reimbursement?
        status = ReportStatus.closed_id
      end
    end
    curr_user_role = User::Team::Review::UserRole.(user, self.report)
    update_attributes = {report_status_id: status, controlling_user: manager, controlling_for_user_id: nil,
                         controlling_user_role_id: to_user_role_id, controlling_for_user_role_id: nil, memo: nil}
    update_attributes[:submitted_at] = DateTime.now if auto_approve
    if report.update_attributes update_attributes
      if auto_approve
        track = report.tracks.build action_user: nil, modified_user: nil,
                                    report_tracking_action_id: ReportTrackingAction.auto_approve_id,
                                    report_status_id: status
      else
        track = report.tracks.build action_user: user, modified_user_id: report.controlling_user_id,
                                    modified_user_role_id: to_user_role_id,
                                    report_tracking_action_id: ReportTrackingAction.approve_id, report_status_id: status,
                                    user_report_role_id: curr_user_role
      end
      track.save

      if report.closed?
        track = report.tracks.build action_user: nil, modified_user: nil,
                                    report_tracking_action_id: ReportTrackingAction.closed_id,
                                    report_status_id: ReportStatus.closed_id
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
        Settlement::Report::Approved.(user, report: report, auto_approve: auto_approve)
        report.reload
      end
      # if report is closed, add the relevant comment
      if report.closed?
        # Add comments stating report has been closed as no reimbursements required
        comment = report.comments.build user: nil, report_comment_action_id: ReportCommentAction.id_for(:report_closed)
        comment.save
      end
      # Send notifications
      Event::EReport::Approve.(self.user, report: self.report, auto_approve: auto_approve)

      messages[:success] << 'Report approved!'
    end
  end

end
# action to unapprove a report
# params:
# report_id: id of the report to be unapproved

class Report::Unapprove < Report::Base
  attr_accessor :prev_status

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'User or params not passed'
    end
  end

  def init
    id = (params[:report_id] or params[:id])
    self.report = Report.find_by(id: id)
  end

  def authorize
    super
    if report.user_id == user.id
      messages[:error] << 'You cannot unapprove your own report'
      raise_unauthorized_exception
    end
  end

  def validate
    # checking if this user can unapprove this report at this stage
    associated_users = report.associated_users report.controlling_user
    unless associated_users.present? and associated_users.with_id(user.id).present?
      messages[:error] << 'User has not yet reviewed the report to unapprove it'
      return false
    end

    unless report.can_unapprove?
      messages[:error] << 'The report cannot be unapproved at this stage'
    end
  end

  def process
    self.prev_status = report.status
    if report.update_attributes controlling_user_id: user.id, controlling_for_user_id: nil, memo: nil, report_status_id: ReportStatus.processing_id
      report.tracks.create action_user: user, report_tracking_action_id: ReportTrackingAction.unapprove_id, report_status_id: ReportStatus.processing_id
      return
    end
    messages[:error] << report.errors.full_messages
  end

  def post_process
    report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_unapprove)
    # Recalculate settlement when report is unapproved from an approved/closed state
    if prev_status.approved? or prev_status.closed?
      Settlement::Report::Unapproved.(user, report: report)
    end

    messages[:success] << "Report unapproved."
  end
end
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
      errors << "User or params not passed."
    end
  end

  def init
    self.report = Report.find_by(id: params[:report_id])
  end

  def validate
    unless report.can_unapprove?
      errors << "THe report cannot be unapproved at this stage."
    end
  end

  def authorize
    if report.user_id == user.id
      errors << "You cannot unapprove your own report."
      return false
    end

    # checking if this user can unapprove this report at this stage
    associated_users = report.associated_users report.controlling_user
    unless associated_users.present? and associated_users.with_id(user.id).present?
      errors << 'User has not yet reviewed the report to unapprove it'
      return false
    end
  end

  def process
    self.prev_status = report.status
    if report.update_attributes controlling_user_id: user.id, controlling_for_user_id: nil, memo: nil, report_status_id: ReportStatus.processing_id
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.unapprove_id, report_status_id: ReportStatus.processing_id
      track.save
      return true
    end
    errors << report.errors.full_messages
  end

  def post_process
    if is_success?
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_unapprove_id
      comment.save
      # Recalculate settlement when report is unapproved from an approved/closed state
      if prev_status.approved? or prev_status.closed?
        SettlementService.new.report_unapproved report
      end
    end
  end
end
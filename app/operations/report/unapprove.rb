# action to unapprove a report
# params:
# report_id: id of the report to be unapproved

class Report::Unapprove < Report::Base
  attr_accessor :prev_status, :from_user

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'User or params not passed'
    end
  end

  def init
    id = (params[:report_id] or params[:id])
    self.report = Report.find_by(id: id)
    if report.present?
      self.from_user = self.report.controlling_user
    end
  end

  def authorize
    super
    if report.user_id == user.id
      add_message :error, 'You cannot unapprove your own report'
      raise_unauthorized_exception
    end
  end

  def validate
    # checking if this user can unapprove this report at this stage
    associated_users = Report::AssociatedUsers.(self.user, report: self.report, user_before: report.controlling_user)
    unless associated_users.present? or associated_users.with_id(user.id).present?
      add_message :error, 'User has not yet reviewed the report to unapprove it'
      return false
    end

    unless report.can_unapprove?
      add_message :error, 'The report cannot be unapproved at this stage'
    end
  end

  def process
    prev_controlling_user = (report.controlling_for_user or report.controlling_user)
    prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.report)
    role_id = nil
    # Todo verify if the user has approved the report as manager / finance manager
    if manager_view?
      role_id = UserRole.id_for(:manager)
    elsif finance_view?
      role_id = UserRole.id_for(:finance_manager)
    end
    self.prev_status = report.status
    if report.update_attributes controlling_user_id: user.id,
                                controlling_for_user_id: nil,
                                controlling_user_role_id: role_id,
                                controlling_for_user_role_id: nil,
                                report_status_id: ReportStatus.processing_id,
                                approved_at: nil
      report.tracks.create action_user: user,
                           action_user_role_id: role_id,
                           modified_user: prev_controlling_user,
                           modified_user_role_id: prev_controlling_user_role,
                           report_tracking_action_id: ReportTrackingAction.id_for(:unapprove),
                           report_status_id: ReportStatus.processing_id
      return
    end
    add_message :error, report.errors.full_messages
  end

  def post_process
    report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_unapprove)
    # Recalculate settlement when report is unapproved from an approved state
    if prev_status.approved?
      Settlement::Report::Unapproved.(user, report: report)
    end
    EmailAuthorization::Invalidate.(user, authorizable: report)
    EmailAuthorization::Create.(user, {authorizable: report})

    # If its sending mail to previous guy, send token again to him, need to pass token todo
    Event::EReport::Unapprove.(self.user, report: report)
    add_message :success, 'Report unapproved'
  end
end
# retracting a report that isn't currently in a processing state
# params:
# report_id: id of the report that is being retracted

class Report::Retract < Report::Base
  attr_accessor :from_user, :prev_status

  def personalizer
    {
        pre_process: {
            before: Personalizer::Process.new([:report, :retract], :pre_process, self)
        }
    }
  end

  def authorized_user_types
    :employee
  end

  def pre_validate
    super
    id = (params[:id] or params[:report_id])
    if id.blank?
      add_message :error, 'Error loading report'
    end
    validate_delegator_action if actual_current_user.present?
  end

  def init
    id = (params[:id] or params[:report_id])
    self.report = user.reports.with_id(id).first rescue nil
    if self.report.present?
      self.from_user = report.controlling_user
    end
  end

  def authorize
    super
    unless report.user_id == user.id
      add_message :error, 'Only report owners can retract report'
    end
  end

  def validate
    unless report.can_retract?
      add_message :error, 'Cannot retract report which is not in processing state'
    end
  end

  def process
    self.prev_status = report.status
    prev_controlling_user = (report.controlling_for_user or report.controlling_user)
    prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.report)
    role_id = UserRole.id_for(:employee)
    if report.update_attributes report_status_id: ReportStatus.retracted_id,
                                controlling_user_id: user.id,
                                controlling_for_user_id: nil,
                                controlling_user_role_id: role_id,
                                controlling_for_user_role_id: nil,
                                submitted_at: nil, auto_submit: false
      delegated_action_user = actual_current_user.present? ? actual_current_user : nil
      track = report.tracks.build action_user: user,
                                  action_user_role_id: role_id,
                                  modified_user: prev_controlling_user,
                                  modified_user_role_id: prev_controlling_user_role,
                                  report_tracking_action_id: ReportTrackingAction.id_for(:retract),
                                  report_status_id: ReportStatus.retracted_id,
                                  delegated_action_user: delegated_action_user
      track.save
      report.expenses.update_all(expense_status_id: ExpenseStatus.id_for(:unsubmitted))
      return
    end
    add_message :error, report.errors.full_messages
  end

  def post_process
    delegated_action_user = actual_current_user.present? ? actual_current_user : nil
    report_comment_action = actual_current_user.present? ? :report_retracted_by_delegate : :report_retract 
    report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(report_comment_action), delegated_action_user: delegated_action_user
    # destroying the submitted amount field
    report.submitted_amount&.destroy

    if prev_status.approved? || report.auto_approve
      op = Settlement::SReport::Unapproved.(user, report: report)
      report.update(auto_approve: false)
    end

    # Invalidate All existing Email Authorizations
    email_auth_invalidate_presenter = EmailAuthorization::Invalidate.(user, authorizable: report)

    Event::EReport::Retract.(user, report: report, from_user: from_user)

    add_message :success, 'Report retracted!'
  end

end
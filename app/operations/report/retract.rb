# retracting a report that isn't currently in a processing state
# params:
# report_id: id of the report that is being retracted

class Report::Retract < Report::Base
  attr_accessor :from_user

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
    self.report = user.reports.with_id(id).first rescue nil
    if self.report.present?
      self.from_user = report.controlling_user
    end
  end

  def authorize
    super
    unless report.user_id == user.id
      messages[:error] << 'Only report owners can retract report'
    end
  end

  def validate
    unless report.processing?
      messages[:error] << 'Cannot retract report which is not in processing state'
    end
  end

  def process
    prev_controlling_user = (report.controlling_for_user or report.controlling_user)
    prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.report)
    role_id = UserRole.id_for(:employee)
    if report.update_attributes report_status_id: ReportStatus.retracted_id,
                                controlling_user_id: user.id, controlling_for_user_id: nil,
                                controlling_user_role_id: role_id, controlling_for_user_role_id: nil,
                                memo: nil, submitted_at: nil, auto_submit: false
      track = report.tracks.build action_user: user, modified_user: prev_controlling_user,
                                  modified_user_role_id: prev_controlling_user_role,
                                  report_tracking_action_id: ReportTrackingAction.retract_id,
                                  report_status_id: ReportStatus.retracted_id
      track.save
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.unsubmitted_id)
      end
      return
    end
    messages[:error] = report.errors.full_messages
  end

  def post_process
    report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_retract)

    Event::EReport::Retract.(user, report: report, from_user: from_user)

    messages[:success] << 'Report retracted!'
  end

end
# action to submit a report.

# params:
# report_id: id of the report that needs to be submitted
# controlling_for_user_id: if a user is submitting a report for someone else

class Report::Submit < Report::Base

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve] or params[:auto_submit])
    [:employee]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
    if user.blank? and not params[:auto_approve] and not params[:auto_submit]
      add_message :error, 'User not found'
    end
  end

  def init
    id = (params[:report_id] or params[:id])
    self.report = user.reports.find_by(id: id)
  end

  def validate
    # checking report status
    unless report.can_submit?
      add_message :error, 'Cannot submit this report'
      return false
    end
    # checking if the report has expenses
    unless report.expenses.present?
      add_message :error, 'Cannot submit an empty report'
    end
    # checking for blocking violations
    violations = Report::Violation.(user, report: report)
    violations_present = false
    violations.each do |key, value|
      if value['expense_blocking'].present? or value['budget_blocking'].present?
        violations_present = true
      end
    end
    if violations_present
      add_message :error, 'Reports with blocking violations cannot be submitted'
    end
  end

  def authorize
    unless report
      raise_unauthorized_exception
      return false
    end
    # # if submitting a report for someone else, ensure he has the right to
    # if params[:controlling_for_user_id]
    #   unless report.controlling_for_user_id == user.id
    #     raise_unauthorized_exception
    #     return false
    #   end
    # else

    # Only report owners can submit report
    unless report.user_id == user.id
      raise_unauthorized_exception
    end
  end

  def process
    presenter = User::Team::Review::NextReviewer.(report)
    manager = presenter.user
    manager_role_id = presenter.role_id
    # If no manager assigned, auto approve the report
    if manager.blank?
      # call the approve class with the right parameters
      approve_op = Report::Approve.new(user, {report: report, auto_approve: true})
      unless approve_op.run.success?
        self.add_message :error, approve_op.messages[:error]
        return false
      end
      report.reload
      # changing the status of the expenses in the auto approved report.
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.submitted_id)
      end
      return true
    end
    submitted_at = DateTime.now
    if report.update_attributes report_status_id: ReportStatus.processing_id,
                                controlling_user_id: manager.id,
                                controlling_for_user_id: nil,
                                controlling_user_role_id: manager_role_id,
                                controlling_for_user_role_id: nil,
                                submitted_at: submitted_at
      report.tracks.create action_user: user,
                           action_user_role_id: UserRole.id_for(:employee),
                           modified_user_id: report.controlling_user_id,
                           modified_user_role_id: manager_role_id,
                           report_tracking_action_id: ReportTrackingAction.id_for(:submit),
                           report_status_id: ReportStatus.processing_id
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.submitted_id)
      end
      return true
    end
    add_message :error, report.errors.full_messages
  end

  def post_process
    # adding comment regarding the change in status of this report
    report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_submit)

    Event::EReport::Submit.(user, report: report)

    add_message :success, 'Report Submitted'

  end

end
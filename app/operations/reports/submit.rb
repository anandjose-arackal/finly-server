# action to submit a report.

# params:
# report_id: id of the report that needs to be submitted
# controlling_for_user_id: if a user is submitting a report for someone else

class Reports::Submit < Reports::Base
  attr_accessor :has_violations, :workflow_output

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
    unless report.valid?
      add_message :error, report.errors.full_messages
      return
    end
    # checking report status
    unless report.can_submit?
      add_message :error, 'Cannot submit this report'
      return false
    end
    # checking if the report has expenses
    unless report.expenses.present?
      add_message :error, 'Cannot submit an empty report'
    end
    # checking if policy is added if enforce policy is enabled
    if user.enforce_policy_enabled?
      if report.policy.nil?
        add_message :error, 'You have to select a policy for the report before submission'
        return false
      end
    end
    # checking for blocking violations
    violations = Reports::Violation.(user, report: report)
    blocking_violations_present = false
    violations.each do |key, value|
      blocking_violations_present ||= (value['expense_blocking'].present? or value['budget_blocking'].present?)
      self.has_violations ||= (blocking_violations_present or  value['budget_warning'].present? or value['expense_warning'].present?)
      break if blocking_violations_present
    end
    if blocking_violations_present
      add_message :error, 'Reports with blocking violations cannot be submitted'
    end

    custom_field_validations = CustomField::Validate.(report)
    unless custom_field_validations.success?
      add_message :error, custom_field_validations.messages[:error]
    end
  end

  def authorize
    unless report
      raise_unauthorized_exception
      return false
    end

    # Only report owners can submit report
    unless report.user_id == user.id
      raise_unauthorized_exception
    end
  end

  def process
    # presenter = User::Team::Review::NextReviewer.(report, has_violations: self.has_violations)
    # manager = presenter.user
    # manager_role_id = presenter.role_id
    # # If no manager assigned, auto approve the report
    # if manager.blank?
    #   # call the approve class with the right parameters
    #   approve_op = Reports::Approve.(user, {report: report, auto_approve: true})
    #   unless approve_op.success?
    #     self.add_message :error, approve_op.messages[:error]
    #     return false
    #   end
    #   report.reload
    #   # changing the status of the expenses in the auto approved report.
    #   report.expenses.each do |expense|
    #     expense.update_attribute(:expense_status_id, ExpenseStatus.id_for(:verified))
    #   end
    #   return true
    # end
    # submitted_amount_attributes = {value: report.total_amount, currency_id: 1}
    # if report.submitted_amount
    #   submitted_amount_attributes[:id] = report.submitted_amount_id
    # end
    # submitted_at = DateTime.now
    # if report.update_attributes report_status_id: ReportStatus.processing_id,
    #                             controlling_user_id: manager.id,
    #                             controlling_for_user_id: nil,
    #                             controlling_user_role_id: manager_role_id,
    #                             controlling_for_user_role_id: nil,
    #                             submitted_at: submitted_at,
    #                             submitted_amount_attributes: submitted_amount_attributes
    #   report.tracks.create action_user: user,
    #                        action_user_role_id: UserRole.id_for(:employee),
    #                        modified_user_id: report.controlling_user_id,
    #                        modified_user_role_id: manager_role_id,
    #                        report_tracking_action_id: ReportTrackingAction.id_for(:submit),
    #                        report_status_id: ReportStatus.processing_id
    #   unless report.approved?
    #     report.expenses.each do |expense|
    #       expense.update_attribute(:expense_status_id, ExpenseStatus.submitted_id)
    #     end
    #   end
    #   return true
    # end
    # add_message :error, report.errors.full_messages
    params[:document] = self.report
    params[:aasm_event] = 'submit'
    params[:violation_present] = false
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process

    # Creating Email Authorization

    # If report is processing
    email_authorization = nil
    # email_authorization_presenter = EmailAuthorization::Create.(user, {authorizable: report})
    if report.processing?
      report.reload
      email_authorization_presenter = EmailAuthorization::Create.(user, {authorizable: report})
      if email_authorization_presenter.success?
        email_authorization = email_authorization_presenter.email_authorization
      end
    end

    # If report is auto approved


    # Email Authorization Ends

    # adding comment regarding the change in status of this report
    report.comments.create user: user, report_comment_action_id: ReportCommentAction.id_for(:report_submit)

    Event::EReport::Submit.(user, {email_authorization: email_authorization, report: report})

    add_message :success, 'Report Submitted'

  end

end
# action that approves a report.
# params:
# report_id: id of the report that needs to be approved
# auto_approve : optional - set to true if the report is to be auto-approved. i.e. if there is no reporting manager

class Reports::Approve < Reports::Base
  attr_accessor :auto_approve, :auto_submit, :has_violations

  def personalizer
    {
        pre_process: {
            before: Personalizer::Process.new([:report, :approve], :pre_process, self)
        }
    }
  end

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve] or params[:auto_submit] )
    [:manager, :finance_manager, :admin]
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
    self.report = params[:report]
    if self.report.blank?
      id = (params[:id] or params[:report_id])

      # self.report = user.controlling_reports.with_id(id).first rescue nil
      self.report = Report.reviewer_associated_items(user).with_id(id).first rescue nil
    end
    self.auto_approve = (params[:auto_approve] or false)
    self.auto_submit = params[:auto_submit]
  end

  def authorize
    unless report
      raise_unauthorized_exception
    end
    # unless auto_approve or report.controlling_user_id == user.id
    #   raise_unauthorized_exception
    # end
  end

  def validate
    # Will be moved to workflow manager
    # unless report.processing?
    #   add_message :error, 'Cannot approve this report as it is not in processing state'
    # end

    violations = Reports::Violation.(user, report: report)
    violations_present = false
    violations.each do |key, value|
      blocking_violations_present ||= (value['expense_blocking'].present? or value['budget_blocking'].present?)
      self.has_violations ||= (blocking_violations_present or  value['budget_warning'].present? or value['expense_warning'].present?)
      break if blocking_violations_present
    end
    if violations_present
      add_message :error, 'Reports with blocking violations cannot be approved'
    end
  end

  def process
    ############
    # approved_at,
    #############
    # presenter = User::Team::Review::NextReviewer.(report, has_violations: self.has_violations)
    # manager = presenter.user
    # to_user_role_id = presenter.role_id
    # status = ReportStatus.processing_id
    # if auto_approve or manager.blank?
    #   status = ReportStatus.approved_id
      # if the report has no reimbursable expenses, mark it as closed because there are no reimbursements
      # if report.expenses.only_reimbursable_expenses.count == 0
      #   status = ReportStatus.closed_id
      # end
    # end
    # if status == ReportStatus.approved_id || status == ReportStatus.closed_id
    #   approved_at = DateUtils.local_date_time
    # else
    #   approved_at = nil
    # end
    # curr_user_role = User::Team::Review::UserRole.(user, self.report)
    # update_attributes = {report_status_id: status,
    #                      controlling_user: manager,
    #                      controlling_for_user_id: nil,
    #                      controlling_user_role_id: to_user_role_id,
    #                      controlling_for_user_role_id: nil,
    #                      auto_approve: auto_approve,
    #                      approved_at: approved_at}
    # update_attributes[:submitted_at] = DateTime.now if auto_approve
    # if report.update_attributes update_attributes
    #   if auto_approve
    #     track = report.tracks.build action_user: nil,
    #                                 modified_user: nil,
    #                                 report_tracking_action_id: ReportTrackingAction.id_for(:auto_approve),
    #                                 report_status_id: status
    #   else
    #     track = report.tracks.build action_user: user,
    #                                 modified_user_id: report.controlling_user_id,
    #                                 modified_user_role_id: to_user_role_id,
    #                                 report_tracking_action_id: ReportTrackingAction.id_for(:approve),
    #                                 report_status_id: status,
    #                                 action_user_role_id: curr_user_role
    #   end
    #   track.save
    #
    #   if report.closed?
    #     track = report.tracks.build action_user: nil,
    #                                 modified_user: nil,
    #                                 report_tracking_action_id: ReportTrackingAction.id_for(:closed),
    #                                 report_status_id: ReportStatus.closed_id
    #     track.save
    #   end
    #   return true
    # end
    # add_message :error, report.errors.full_messages


    ###################
    # NEW CODE
    #  Workflow Manager
    params[:document] = self.report
    params[:aasm_event] = 'approve'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
    # NEW CODE ENDS
    ####################
  end

  def post_process
    if success?
      if auto_approve
        comment = report.comments.build report_comment_action_id: ReportCommentAction.id_for(:report_auto_approve)
      else
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_approve)
      end
      comment.save

      email_authorization = nil

      # set the reimbursement amount of the report
      if report.processing?
        email_auth_invalidate_presenter = EmailAuthorizations::Invalidate.(user, authorizable: report)
        email_authorization_presenter = EmailAuthorizations::Create.(user, {authorizable: report})
        if email_authorization_presenter.success?
          email_authorization = email_authorization_presenter.email_authorization
        end
      else
        op = Settlement::SReport::Approved.(user, report: report, auto_approve: auto_approve)
        report.reload

        report.expenses.update_all(expense_status_id: ExpenseStatus.id_for(:verified))

        # Mark all previous tokens as invalid
        email_auth_invalidate_presenter = EmailAuthorizations::Invalidate.(user, authorizable: report)
        # unless email_auth_invalidate_presenter.success?

        # end
      end
      # if report is closed, add the relevant comment
      if report.closed?
        # Add comments stating report has been closed as no reimbursements required
        comment = report.comments.build(user: nil,
                                        report_comment_action_id: ReportCommentAction.id_for(:report_closed),
                                        content: " as there are no reimbursable expenses")
        comment.save
      end
      # Send notifications
      # Role is params[:view]
      role_id = self.workflow_output[:role_id]
      Event::EReport::Approve.(self.user, {report: self.report, auto_approve: auto_approve, email_authorization: email_authorization, role_id: role_id})

      add_message :success, 'Report approved!'
    end
  end

end
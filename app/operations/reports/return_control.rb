# action that takes control of the report when it is in processing state.
# params:
# report_id: id of the report that needs to be taken control of
# memo: optional memo from the user taking control of the report.

class Reports::ReturnControl < Reports::Base

  def authorized_user_types
    [:admin]
  end

  def init
    report_id = params[:id] || params[:report_id]
    self.report = Report.admin_associated_items(user).find_by report_id
  end

  def authorize
    super
    if not user.company_admin? and user.policy_admin?
      if report.policy and not user.policy_admin?(report.policy) # that is the report has a policy and the user is not policy admin
        raise_unauthorized_exception
      end
    end
  end

  def validate
    unless report.can_return_control?
      messages[:error] << 'Report cannot be returned control of at this stage'
    end
  end

  def process
    # if report.update_attributes controlling_user: user,
    #                             controlling_for_user: report.controlling_user,
    #                             controlling_user_role_id: UserRole.id_for(:admin),
    #                             controlling_for_user_role_id: report.controlling_user_role_id
    #   track = report.tracks.build action_user: user,
    #                               action_user_role_id: UserRole.id_for(:admin),
    #                               modified_user_id: report.controlling_for_user_id,
    #                               modified_user_role_id: report.controlling_for_user_role_id,
    #                               report_tracking_action_id: ReportTrackingAction.id_for(:take_control),
    #                               report_status_id: report.status_id
    #   track.save
    #   return
    # end
    # self.messages = report.errors.full_messages

    #  Workflow Manager
    params[:document] = self.report
    params[:aasm_event] = 'return_control'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # if success?
    #   comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_take_control), content: params[:take_control_note]
    #   comment.save
    # end
    # Event::EReport::TakeControl.(self.user, report: self.report)

    messages[:success] << "You've returned control of this report."
  end

end
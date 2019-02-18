# action that confirms whether a report has been reimbursed

class Reports::SettlementConfirm < Reports::Base

  def authorized_user_types
    [:employee]
  end

  def init
    super()
  end

  def validate
    unless report.settled?
      add_message :error, 'Report cannot be confirm reimbursement as the report is not marked as reimbursed'
    end
  end

  def process
    # if report.update_attributes controlling_user: nil,
    #                             controlling_for_user: nil,
    #                             controlling_user_role_id: nil,
    #                             controlling_for_user_role_id: nil,
    #                             report_status_id: ReportStatus.settlement_confirmed_id
    #   track = report.tracks.build action_user: user,
    #                               action_user_role_id: UserRole.id_for(:employee),
    #                               modified_user: user,
    #                               modified_user_role_id: UserRole.id_for(:employee),
    #                               report_tracking_action_id: ReportTrackingAction.id_for(:settlement_confirmed),
    #                               report_status_id: ReportStatus.settlement_confirmed_id
    #   track.save
    #   return true
    # end
    # add_message :error, 'Report could not be marked as settled. Please try again'


    # New code
    #  Workflow Manager
    params[:document] = self.report
    params[:aasm_event] = 'settlement_confirm'
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
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_settlement_confirmed)
      comment.save
      add_message :success, 'Report settlement confirmed'
    end
  end
end
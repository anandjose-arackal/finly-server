class TravelRequests::Review::ApproveSelection < TravelRequests::Review::ConfirmSelection

  def process
    #NEW CODE
    #  Workflow Manager
    params[:document] = self.travel_request
    params[:aasm_event] = 'approve_selection'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    travel_request.comments.create user_id: user.id,
                                   action_id: TravelRequestCommentAction.id_for(:selection_approved)
    #todo abi - money request special status
    # travel_request.money_requests.status_pending.update_all(
    #     controlling_user_id: travel_request.controlling_user_id,
    #     controlling_user_role_id: travel_request.controlling_user_role_id
    # )
    Event::ETravelRequest::ApproveSelection.(user, travel_request: travel_request)
    add_message :success, 'Selection has been successfully approved'
  end

  protected
  def trail_action_id
    TravelRequestTrailAction.id_for(:selection_approved)
  end
end
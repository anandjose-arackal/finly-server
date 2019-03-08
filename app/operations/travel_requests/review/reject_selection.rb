class TravelRequests::Review::RejectSelection < TravelRequests::Review::Base

  def init
    travel_request_presenter = TravelRequests::Show.(user, params)
    unless travel_request_presenter.success?
      add_message :error, travel_request_presenter.messages[:error]
      return
    end
    self.travel_request = travel_request_presenter.travel_request
  end

  def validate
    # unless self.travel_request.controlling_user_id == user.id
    #   add_message :error, 'You cannot perform this action at the moment'
    #   return
    # end
    unless manager_view?
      add_message :error, 'You cannot perform this action at the moment'
      return
    end
    unless self.travel_request.selection_processing?
      add_message :error, 'You cannot perform this action at the moment'
      return
    end
  end

  def process
    # selector, selector_role_id = travel_booking_selector
    # controlling_user_role_id = travel_request.controlling_user_role_id
    # # Set reviewer as controlling user
    # if travel_request.update_attributes status_id: TravelRequestStatus.id_for(:selection_rejected),
    #                                     controlling_user_id: selector&.id,
    #                                     controlling_user_role_id: selector_role_id
    #
    #   travel_request.travel_request_trails.create action_user: user,
    #                                               action_user_role_id: controlling_user_role_id,
    #                                               action_id: TravelRequestTrailAction.id_for(:selection_rejected),
    #                                               modified_user_id: selector&.id,
    #                                               modified_user_role_id: controlling_user_role_id
    #
    #   travel_request.money_requests.status_pending.update_all(
    #       controlling_user: travel_request.controlling_user,
    #       controlling_user_role_id: travel_request.controlling_user_role_id
    #   )
    # else
    #   add_message :error, travel_request.errors.full_messages
    # end

    #NEW CODE
    #  Workflow Manager
    params[:document] = self.travel_request
    params[:aasm_event] = 'reject_selection'
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
                                   action_id: TravelRequestCommentAction.id_for(:selection_rejected)
    Event::ETravelRequest::RejectSelection.(user, travel_request: travel_request)
    add_message :success, 'Selection has been rejected'
  end

  protected

  # Check if the user has a selector configured, use the selector. Else the owner becomes the selector
  def travel_booking_selector
    purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])
    selector = self.travel_request.user.team_mapping.with_purpose(purpose_id)
                   .policy(self.travel_request.policy_id).default.first&.travel_booking_selector
    if selector.present?
      return [selector, UserRole.id_for(:manager)]
    end
    [self.travel_request.user, UserRole.id_for(:employee)]
  end

end
class TravelRequests::Review::Retract < TravelRequests::Review::Base

  attr_accessor :from_user

  def authorized_user_types
    [:employee]
  end

  def validate
    unless travel_request.user_id == user.id
      add_message :error, "Only Owners can retract their travel requests"
      return
    end

    unless travel_request.can_retract?
      add_message :error, "Travel Request cannot be retracted in this state"
      return
    end
  end

  def process
    # delegated_action_user_id = actual_current_user.present? ? actual_current_user.id : nil
    # prev_controlling_user = (travel_request.controlling_user or travel_request.controlling_for_user)
    # prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.travel_request)
    # if travel_request.update status_id: TravelRequestStatus.id_for(:retracted),
    #                          controlling_user_id: user.id,
    #                          controlling_user_role_id: UserRole.id_for(:employee),
    #                          controlling_for_user_id: nil,
    #                          controlling_for_user_role_id: nil
    #   travel_request.travel_request_trails.create action_user: user,
    #                                               action_user_role_id: UserRole.id_for(:employee),
    #                                               action_id: TravelRequestTrailAction.id_for(:retract),
    #                                               delegated_action_user_id: delegated_action_user_id,
    #                                               modified_user: prev_controlling_user,
    #                                               modified_user_role_id: prev_controlling_user_role
    #   return true
    # end
    # add_message :error, travel_request.errors.full_messages
    params[:document] = self.travel_request
    params[:aasm_event] = 'retract'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    delegated_action_user_id = actual_current_user.present? ? actual_current_user.id : nil
    tr_comment_action = actual_current_user.present? ? :retracted_by_delegate : :retract
    # add comments
    self.travel_request.comments.create(user_id: user.id,
                                         action_id: TravelRequestCommentAction.id_for(tr_comment_action), delegated_action_user_id: delegated_action_user_id)

    #todo - abi
    travel_request.money_requests.status_pending.update_all(
        controlling_user_id: travel_request.controlling_user_id,
        controlling_user_role_id: travel_request.controlling_user_role_id
    )
    #
    # Event::EBankPaymentRequest::Retract.(user, travel_request: travel_request)
    role_id = self.workflow_output[:role_id]
    Event::ETravelRequest::Retract.(user, travel_request: travel_request, role_id: role_id)
    add_message :success, "Travel Request retracted successfully"
  end

end
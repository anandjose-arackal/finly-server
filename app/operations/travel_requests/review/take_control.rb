class TravelRequests::Review::TakeControl < TravelRequests::Review::Base

  def authorized_user_types
    [:admin]
  end

  def authorize
    super
    if not user.company_admin? and user.policy_admin?
      if travel_request.policy and not user.policy_admin?(travel_request.policy) and not user.company_admin? # that is the money_request has a policy and the user is not policy admin
        raise_unauthorized_exception
        return false
      end
    end
  end

  def validate
    unless travel_request.can_take_control?
      messages[:error] << 'You cannot take control of a travel request unless it is processing'
      return
    end
  end

  def process
    # memo = (params[:note] or params[:memo] or travel_request.memo)
    # action_for_user_id = travel_request.controlling_for_user_id
    # action_for_user_role_id = travel_request.controlling_for_user_role_id
    # prev_controlling_user = (travel_request.controlling_user or travel_request.controlling_for_user)
    # prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.travel_request)
    # if travel_request.update_attributes controlling_user: user,
    #                                     controlling_for_user: travel_request.controlling_user,
    #                                     controlling_user_role_id: UserRole.id_for(:admin),
    #                                     controlling_for_user_role_id: travel_request.controlling_user_role_id
    #   travel_request.travel_request_trails.create action_user: user,
    #                                action_user_role_id: UserRole.id_for(:admin),
    #                                modified_user_id: travel_request.controlling_for_user_id,
    #                                modified_user_role_id: travel_request.controlling_for_user_role_id,
    #                                action_id: TravelRequestTrailAction.id_for(:take_control)
    #
    #   travel_request.travel_request_trails.create action_user: user,
    #                                               action_user_role_id: UserRole.id_for(:admin),
    #                                               action_for_user_id: action_for_user_id,
    #                                               action_for_user_role_id: action_for_user_role_id,
    #                                               action_id: TravelRequestTrailAction.id_for(:approve),
    #                                               modified_user: prev_controlling_user,
    #                                               modified_user_role_id: prev_controlling_user_role
    #   # travel_request.comments.create user: user,
    #   #                               comment_action_id: MoneyRequestCommentAction.id_for(:take_control),
    #   #                               content: params[:take_control_note]
    #   return
    # end
    # self.messages = travel_request.errors.full_messages


    #  Workflow Manager
    params[:document] = self.travel_request
    params[:aasm_event] = 'take_control'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output

    self.travel_request.money_requests.each do |money_request|
      parameters = {
        document: money_request,
        aasm_event: 'take_control',
        provider_name: 'TravelRequestProvider'
      }

      money_request_op = WorkflowManager::Base.(user, parameters)
    end
  end

  def post_process
    travel_request.comments.create user: user,
                                   action_id: TravelRequestCommentAction.id_for(:take_control),
                                   content: params[:take_control_note]

    # # Event::EMoneyRequest::TakeControl.(self.user, travel_request: self.travel_request)
    
    # todo Rais - check & test mailers
    role_id = self.workflow_output[:role_id]
    Event::ETravelRequest::TakeControl.(user, travel_request: travel_request, role_id: role_id)

    add_message :success, "You've taken control of this trip"
  end
end

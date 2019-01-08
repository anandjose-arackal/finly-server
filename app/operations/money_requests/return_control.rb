class MoneyRequests::ReturnControl < MoneyRequests::Base

  def authorized_user_types
    [:admin]
  end

  def init
    money_request_id = params[:id] || params[:money_request_id]
    self.money_request = MoneyRequest.admin_associated_items(user).find_by money_request_id
  end

  def authorize
    super
    if not user.company_admin? and user.policy_admin?
      if money_request.policy and not user.policy_admin?(money_request.policy) and not user.company_admin? # that is the money_request has a policy and the user is not policy admin
        raise_unauthorized_exception
        return false
      end
    end
  end

  def validate
    unless money_request.can_take_control?
      messages[:error] << 'You cannot take control of a request unless its in processing or approved state'
    end
  end

  def process
    # memo = (params[:note] or params[:memo] or money_request.memo)
    # if money_request.update_attributes controlling_user: user,
    #                                    controlling_for_user: money_request.controlling_user,
    #                                    controlling_user_role_id: UserRole.id_for(:admin),
    #                                    controlling_for_user_role_id: money_request.controlling_user_role_id
    #   money_request.tracks.create action_user: user,
    #                               action_user_role_id: UserRole.id_for(:admin),
    #                               modified_user_id: money_request.controlling_for_user_id,
    #                               modified_user_role_id: money_request.controlling_for_user_role_id,
    #                               money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:take_control),
    #                               status_id: money_request.status_id
    #   money_request.comments.create user: user,
    #                                 comment_action_id: MoneyRequestCommentAction.id_for(:take_control),
    #                                 content: params[:take_control_note]
    #   return
    # end
    # self.messages = money_request.errors.full_messages

    #  Workflow Manager
    params[:document] = self.money_request
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
    Event::EMoneyRequests::TakeControl.(self.user, money_request: self.money_request)
  end

end
class MoneyRequest::TakeControl < MoneyRequest::Base

  def authorized_user_types
    [:admin]
  end
  
  def authorize
    super
    if user.policy_admin?
      if money_request.policy and not user.policy_admin?(money_request.policy) # that is the money_request has a policy and the user is not policy admin
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
    memo = (params[:note] or params[:memo] or money_request.memo)
    if money_request.update_attributes controlling_user: user, 
                                       controlling_for_user: money_request.controlling_user,
                                       controlling_user_role_id: UserRole.id_for(:admin),
                                       controlling_for_user_role_id: money_request.controlling_user_role_id, 
                                       memo: memo
      money_request.tracks.create action_user: user, modified_user_id: money_request.controlling_for_user_id,
                                  modified_user_role_id: money_request.controlling_for_user_role_id,
                                  money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:take_control),
                                  status_id: money_request.status_id, memo: memo
      money_request.comments.create user: user, 
                                    comment_action_id: MoneyRequestCommentAction.id_for(:take_control),
                                    content: memo
      return
    end
    self.messages = money_request.errors.full_messages
  end

  def post_process

  end

end
class MoneyRequest::TakeControl < MoneyRequest::Base
  attr_accessor :user_role

  def authorized_user_types
    :admin
  end

  def pre_validate
    if params[:id].blank?
      errors << 'Request not found'
    end
    if user.blank?
      errors << 'User not found'
    end
  end

  def init
    self.money_request = MoneyRequest.with_id(params[:id]).first rescue nil
    return if self.money_request.blank?
    self.user_role = User::Team::Review::UserRole.((money_request.controlling_for_user or money_request.controlling_user), self.money_request)
  end

  def authorize
    return if user.company_admin?
    if money_request.blank?
      raise_unauthorized_exception
    end
    unless money_request.processing?
      raise_unauthorized_exception
    end
    # If Policy ID is blank, only company admins can take control
    if money_request.policy_id.blank?
      raise_unauthorized_exception
    end
    policy_id = money_request.policy_id
    unless user.admin_policies.with_id(policy_id).present?
      raise_unauthorized_exception
    end
  end

  def process
    controlling_user_id = money_request.controlling_user.id
    if money_request.update_attributes controlling_for_user_id: controlling_user_id, controlling_user_id: user.id, note: params[:note]
      money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.take_control_id,
                                      status_id: money_request.status_id, user_request_role_id: self.user_role
      self.money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.take_control_id
    else
      errors << money_request.errors.full_messages
    end
  end

end
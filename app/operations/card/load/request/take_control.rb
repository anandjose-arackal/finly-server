class Card::Load::Request::TakeControl < Card::Load::Request::Base
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
    self.card_load_request = CardLoadRequest.with_id(params[:id]).first rescue nil
    return if self.card_load_request.blank?
    self.user_role = User::Team::Review::UserRole.((card_load_request.controlling_for_user or card_load_request.controlling_user), self.card_load_request)
  end

  def authorize
    return if user.company_admin?
    if card_load_request.blank?
      raise_unauthorized_exception
    end
    unless card_load_request.processing?
      raise_unauthorized_exception
    end
    # If Policy ID is blank, only company admins can take control
    if card_load_request.policy_id.blank?
      raise_unauthorized_exception
    end
    policy_id = card_load_request.policy_id
    unless user.admin_policies.with_id(policy_id).present?
      raise_unauthorized_exception
    end
  end

  def process
    controlling_user_id = card_load_request.controlling_user.id
    if card_load_request.update_attributes controlling_for_user_id: controlling_user_id, controlling_user_id: user.id, note: params[:note]
      card_load_request.tracks.create action_user: user, card_load_tracking_action_id: CardLoadTrackingAction.take_control_id,
                                      status_id: card_load_request.status_id, user_request_role_id: self.user_role
    else
      errors << card_load_request.errors.full_messages
    end
  end

end
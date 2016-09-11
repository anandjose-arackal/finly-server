class MoneyRequest::Approve < MoneyRequest::Base
  attr_accessor :to_user, :user_role

  def authorized_user_types
    [:manager, :finance_manager, :admin]
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
    self.money_request = user.controlling_money_requests.with_id(params[:id]).first rescue nil
    return unless self.money_request.present?
    self.to_user = User::Team::Review::NextReviewer.(money_request)
    self.user_role = User::Team::Review::UserRole.((money_request.controlling_for_user or money_request.controlling_user), self.money_request)
  end

  def authorize
    if self.money_request.blank?
      raise_unauthorized_exception
    end
  end

  def process
    if to_user.blank?
      params[:money_request_id] = money_request.id
      Card::Load::LoadCash.(user, params)
    else
      if money_request.update_attributes status_id: MoneyRequestStatus.processing_id, controlling_user_id: to_user.id,
                                             controlling_for_user_id: nil, note: self.params[:note]
        money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.approve_id,
                                        status_id: MoneyRequestStatus.processing_id, user_request_role_id: user_role
        self.money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.approve_id
      else
        errors << money_request.errors.full_messages
      end
    end
  end
end
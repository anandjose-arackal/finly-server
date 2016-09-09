class MoneyRequest::Reject < MoneyRequest::Base
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
    return if self.money_request.blank?
    self.user_role = User::Team::Review::UserRole.((money_request.controlling_for_user or money_request.controlling_user),
        self.money_request)
    if params[:reject_to].present?
      reject_to_users = User::Team::Review::RejectToUsersList.(self.money_request, self.user)
      if reject_to_users.present?
        self.to_user =reject_to_users.with_id(params[:reject_to]).first rescue nil
      end
    else
      self.to_user = self.money_request.user
    end
  end

  def authorize
    if self.money_request.blank?
      errors << 'Cannot find load request'
      raise_unauthorized_exception
    end
    if self.to_user.blank?
      errors << 'Reject to user not found'
      raise_unauthorized_exception
    end
  end

  def process
    status = MoneyRequestStatus.rejected_id
    unless to_user.id == money_request.user.id
      status = MoneyRequestStatus.processing_id
    end
    if money_request.update_attributes status_id: status, controlling_user_id: to_user.id,
                                           controlling_for_user_id: nil, note: self.params[:note]
      money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.reject_id,
                                      status_id: status, user_request_role_id: self.user_role
      self.money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.reject_id
    else
      errors << money_request.errors.full_messages
    end
  end
end
class Card::Load::Request::Reject < Card::Load::Request::Base
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
    self.card_load_request = user.controlling_card_load_requests.with_id(params[:id]).first rescue nil
    return if self.card_load_request.blank?
    self.user_role = User::Team::Review::UserRole.((card_load_request.controlling_for_user or card_load_request.controlling_user),
        self.card_load_request)
    if params[:reject_to].present?
      reject_to_users = User::Team::Review::RejectToUsersList.(self.card_load_request, self.user)
      if reject_to_users.present?
        self.to_user =reject_to_users.with_id(params[:reject_to]).first rescue nil
      end
    else
      self.to_user = self.card_load_request.user
    end
  end

  def authorize
    if self.card_load_request.blank?
      errors << 'Cannot find load request'
      raise_unauthorized_exception
    end
    if self.to_user.blank?
      errors << 'Reject to user not found'
      raise_unauthorized_exception
    end
  end

  def validate
    if self.to_user.blank?
      errors << 'Cannot reject as user not found'
    end
  end

  def process
    status = CardLoadRequestStatus.rejected_id
    unless to_user.id == card_load_request.user.id
      status = CardLoadRequestStatus.processing_id
    end
    if card_load_request.update_attributes status_id: status, controlling_user_id: to_user.id,
                                           controlling_for_user_id: nil, note: self.params[:note]
      card_load_request.tracks.create action_user: user, card_load_tracking_action_id: CardLoadTrackingAction.reject_id,
                                      status_id: status, user_request_role_id: self.user_role
    else
      errors << card_load_request.errors.full_messages
    end
  end
end
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
    requests = user.controlling_card_load_requests.with_id(params[:id])
    self.card_load_request = requests.first if requests.present?
    return if self.card_load_request.blank?
    self.user_role = User::Team::Review::UserRole.((card_load_request.controlling_for_user or card_load_request.controlling_user),
        self.card_load_request)
    if params[:reject_to].present?
      reject_to_users = User::Team::Review::RejectToUsersList.call(self.card_load_request, self.user)
      if reject_to_users.present?
        self.to_user =reject_to_users.with_id(params[:reject_to])
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
  end

  def validate
    if self.to_user.blank?
      errors << 'Cannot reject as user not found'
    end
  end

  def process
    if card_load_request.update_attributes status_id: CardLoadRequestStatus.rejected_id, controlling_user_id: to_user.id,
                                 controlling_for_user_id: nil
      card_load_request.tracks.create action_user: user, card_load_tracking_action_id: CardLoadTrackingAction.reject_id,
                                              status_id: CardLoadRequestStatus.rejected_id, user_request_role: self.user_role
    else
      errors << card_load_request.errors.full_messages
    end
  end
end
class Card::Load::Request::Approve < Card::Load::Request::Base
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
    return unless self.card_load_request.present?
    self.to_user = User::Team::Review::NextReviewer.(card_load_request)
    self.user_role = User::Team::Review::UserRole.((card_load_request.controlling_for_user or card_load_request.controlling_user), self.card_load_request)
  end

  def authorize
    if self.card_load_request.blank?
      raise_unauthorized_exception
    end
  end

  def process
    if to_user.blank?
      params[:card_load_request_id] = card_load_request.id
      Card::Load::LoadCash.(user, params)
    else
      if card_load_request.update_attributes status_id: CardLoadRequestStatus.processing_id, controlling_user_id: to_user.id,
                                   controlling_for_user_id: nil
        card_load_request.tracks.create action_user: user, card_load_tracking_action_id: CardLoadTrackingAction.approve_id,
                                                status_id: CardLoadRequestStatus.processing_id, user_request_role_id: user_role
      else
        errors << card_load_request.errors.full_messages
      end
    end
  end
end
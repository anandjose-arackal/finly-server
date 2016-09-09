class Card::Load::Request::Comment::Create < Card::Load::Request::Base

  def pre_validate
    unless params[:id].present?
      errors << 'Card request ID not found'
    end
    unless params[:content].present?
      errors << 'Nothing to post'
    end
    unless user.blank?
      errors << 'User not found'
    end
  end

  def init
    self.card_load_request = CardLoadRequest.with_id(params[:id]).first rescue nil
  end

  def authorize
    user_id = user.id
    if card_load_request.blank?
      raise_unauthorized_exception
    end
    unless card_load_request.user_id == user_id or card_load_request.controlling_user_id == user_id or
        card_load_request.controlling_for_user_id == user_id or User::Team::IsApprover.(user, card_load_request: card_load_request, type: :manager) or
        User::Team::IsApprover.(user, card_load_request: card_load_request, type: :finance_manager)
      raise_unauthorized_exception
    end
  end

  def process

  end

end
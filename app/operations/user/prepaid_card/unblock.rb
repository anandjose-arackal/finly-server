class User::PrepaidCard::Unblock < User::PrepaidCard::Block

  def validate_status
    card = selected_user.cards.first
    if card.active
      messages[:error] << 'Card is already active'
    end
    disabled_by_role = card.disabled_by_role_id
    curr_role = user_role_id
    if curr_role == UserRole.id_for(:employee) and disabled_by_role != UserRole.id_for(:employee)
      messages[:error] << "The card has been disabled by the #{UserRole.name_for(disabled_by_role)}. You do not have the appropriate permission to enable the card"
    end
  end

  def process
    self.block_presenter = ItzCash::Unblock.(selected_user, params)
    if block_presenter.failure?
      messages[:error] = block_presenter.messages[:error]
    end
  end

  def post_process
    return unless success?
    selected_user.cards.first.update_attributes({active: true, disabled_by_role_id: nil, disable_note: nil})
    if self.block_presenter.present? and self.block_presenter.success?
      messages[:success] << "Successfully blocked the card!"
    end
  end

end

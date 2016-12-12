class User::PrepaidCard::Unblock < User::PrepaidCard::Block

  def validate
    super
    return if has_errors?
    unless selected_user.active
      add_message :error, 'Cannot unblock the card as the user is disabled'
      return
    end
    card = selected_user.cards.first
    if params[:user_deactivation] and not card.disabled_by_role_id.nil?
      add_message :error, 'Cannot unblock card as card was blocked before deactivation'
    end
  end

  def validate_status
    card = selected_user.cards.first
    if card.active
      add_message :error, 'Card is already active'
      return
    end
    disabled_by_role = card.disabled_by_role_id
    curr_role = user_role_id
    if curr_role == UserRole.id_for(:employee) and disabled_by_role != nil and disabled_by_role != UserRole.id_for(:employee) and
        add_message :error, "The card has been disabled by the #{UserRole.name_for(disabled_by_role)}. You do not have the appropriate permission to enable the card"
    end
  end

  def process
    self.block_presenter = ItzCash::Unblock.(selected_user, params)
    if block_presenter.failure?
      add_message :error, block_presenter.messages[:error]
    end
  end

  def post_process
    return unless success?
    selected_user.cards.first.update_attributes({active: true,
                                                 disabled_by_role_id: nil,
                                                 disabled_by_user: nil,
                                                 disable_note: nil})
    if self.block_presenter.present? and self.block_presenter.success?
      add_message :success, 'Successfully unblocked the card!'
    end
  end

end

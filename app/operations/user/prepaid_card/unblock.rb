class User::PrepaidCard::Unblock < User::PrepaidCard::Block

  def validate
    super
    return if has_errors?
    unless self.card.user.active
      add_message :error, 'Cannot unblock the card as the user is disabled'
      return
    end
    curr_role = user_role_id
    if curr_role == UserRole.id_for(:employee) and disabled_by_role != nil and disabled_by_role != UserRole.id_for(:employee) and not self.user.company_admin?
      add_message :error, "The card has been disabled by the #{UserRole.name_for(disabled_by_role)}. You do not have the appropriate permission to enable the card"
    end

    if params[:user_deactivation] and not card.disabled_by_role_id.nil?
      add_message :error, 'Cannot unblock card as the card was blocked before deactivation'
    end
  end

  def process
    self.block_presenter = ItzCash::Unblock.(user, card: self.card)
    if block_presenter.failure?
      add_message :error, block_presenter.messages[:error]
    end
  end

  def post_process
    return unless success?
    card.update_attributes({active: true,
                            disabled_by_role_id: nil,
                            disabled_by_user: nil,
                            disable_note: nil})
    if self.block_presenter.present? and self.block_presenter.success?
      add_message :success, 'Successfully unblocked the card'
    end
  end

end

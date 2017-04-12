class Admin::Cards::Unblock < Admin::Cards::Block

  def process
    unblock_presenter = ItzCash::Unblock.(card.user, {card_id: card.id})
    if unblock_presenter.success?
      selected_card.update(active: true,
                           disbled_by_role_id: UserRole.id_for(:admin),
                           disabled_by_user_id: user.id,
                           admin_unblockable: true)
    else
      add_message :error, unblock_presenter.messages[:error]
    end
  end

  def post_process
    add_message :success, "Card unblocked"
  end
end
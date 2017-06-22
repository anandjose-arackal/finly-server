class Admin::Cards::Unblock < Admin::Cards::Block

  def validate
    if selected_card.active?
      add_message :error, "Card is already active"
    end
  end

  def process
    unblock_presenter = ItzCash::Unblock.(selected_card.user, {card_id: selected_card})
    if unblock_presenter.success?
      selected_card.update(active: true,
                           disabled_by_role_id: nil,
                           disabled_by_user_id: nil,
                           admin_unblockable: true)
    else
      add_message :error, unblock_presenter.messages[:error]
    end
  end

  def post_process
    add_message :success, "Card unblocked"
  end
end
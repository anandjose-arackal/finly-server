class Admin::Cards::Block < Admin::Cards::Base

  attr_accessor :selected_card, :block_params, :update_params

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:card_id]
    self.selected_card = Card.find_by(id: id)
    self.block_params = card_block_params
  end

  def validate
    if selected_card.inactive?
      add_message :error, "Card is already blocked"
    end
  end

  def process
    block_presenter = ItzCash::Block.(selected_card.user, {card_id: selected_card})
    if block_presenter.success?
      selected_card.update(active: false,
                           disabled_by_role_id: UserRole.id_for(:admin),
                           disabled_by_user_id: user.id,
                           admin_unblockable: false)
    else
      add_message :error, block_presenter.messages[:error]
    end
  end

  def post_process
    add_message :success, "Card blocked successfully"
  end

  def success
    Admin::Cards::Base::CardsPresenter.new(user, {card: selected_card}, messages)
  end

  private

  def card_block_params
    params.require(:card).permit(:active)
  end
end
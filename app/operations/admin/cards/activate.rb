# operation that lists all the unassigned cards for a particular company as well as the possible card types for a particular user
# parameters:
# params: {
#   company_id: id of the company for which the cards are being queried
#   user_id: id of the user for which the card is being assigned
# }

class Admin::Cards::Activate < Admin::Cards::Base

  attr_accessor :old_card, :new_card

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end

    if params.dig(:card, :old_card_id).blank? || params.dig(:card, :new_card_id).blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    card_user = User.find_by(id: params[:id])
    self.old_card = card_user.cards.unscoped.find_by(id: active_params[:old_card_id])
    self.new_card = card_user.cards.unscoped.find_by(id: active_params[:new_card_id])
  end

  def validate
  end

  def process
    self.old_card.update_attributes(hotlisted: true)
    self.new_card.update_attributes(
        card_status_id: CardStatus.id_for(:assigned),
        replaced_card_id: old_card.id
    )
  end

  def post_process
    add_message :success, "Card successfully activated"
  end

  def success
    Admin::Cards::Base::CardsPresenter.new(user, {card: self.new_card}, messages)
  end

  private

  def active_params
    params.require(:card).permit(:old_card_id, :new_card_id)
  end
end
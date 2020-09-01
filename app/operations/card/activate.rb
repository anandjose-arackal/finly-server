# operation that lists all the unassigned cards for a particular company as well as the possible card types for a particular user
# parameters:
# params: {
#   company_id: id of the company for which the cards are being queried
#   user_id: id of the user for which the card is being assigned
# }

class Card::Activate < Card::Base

  attr_accessor :old_card,:new_card

  def authorized_user_types
    [:admin_user ]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.old_card = user.cards.unscoped.find_by(id: params[:old_card_id])
    self.new_card = user.cards.unscoped.find_by(id: params[:new_card_id])
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

  end

  def success
    params[:card] = self.new_card
    Card::Show::SuccessPresenter.new(user, params, messages)
  end
end
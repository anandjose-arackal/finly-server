# operation that updates a particular card details - can include assigning it to a particular user, as well as un-assigning it with a
# particular user

class Admin::Cards::Update < Admin::Cards::Base

  attr_accessor :selected_card

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:card_id]
    self.selected_card = Card.find_by(id: id)
  end

  def validate
    if selected_card.blank?
      add_message :error, "Card not found"
    end
  end

  def process
    unless selected_card.update(card_params)
      add_message :error, selected_card.errors.full_messages
    end
  end

  def post_process
    add_message :error, "Card updated"
  end

  def success
    Admin::Cards::Base::CardsPresenter.new(user, {card: selected_card}, messages)
  end

end
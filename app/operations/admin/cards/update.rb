# operation that updates a particular card details - can include assigning it to a particular user, as well as un-assigning it with a
# particular user

class Admin::Cards::Update < Admin::Cards::Base

  attr_accessor :selected_card, :selected_user

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id]
    self.selected_user = User.find_by(id: id)
    self.selected_card = selected_user.cards.find_by(id: params[:card_id]) rescue nil
  end

  def validate
    if selected_user.blank? || selected_card.blank?
      add_message :error, "Card or User not found"
    end
  end

  def process
    unless selected_card.update(card_params)
      add_message :error, selected_card.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Card updated"
  end

  def success
    Admin::Cards::Base::CardsPresenter.new(user, {card: selected_card}, messages)
  end

end
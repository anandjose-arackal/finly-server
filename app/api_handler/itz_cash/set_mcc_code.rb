class ItzCash::SetMccCode < ItzCash::Base

  attr_accessor :selected_card

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless user.cards.present?
      add_message :error, 'A card has not been assigned to the user'
    end
  end

  def init
    self.selected_card = user.cards.first
  end

  def post_params
    {serialid: selected_card.proxy, itzmodule: Constants::ItzCash::MODULE,
     chargecode: card.product_code, newchargecode: ProductCombination::CODES[params[:product_code_id] - 1]}
  end


end
class Admin::Cards::Block < Admin::Cards::Base

  attr_accessor :selected_card

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:card_id]
    self.selected_card = Card.find_by(id: id)
  end

  def process
    block_presenter = ItzCash::Block.(card.user, {card_id: selected_card.id, remarks: "Blocked by Finly"})
    unless block_presenter.success?
      add_message :error, block_presenter.messages[:error]
    end
  end

  def post_process

  end
end
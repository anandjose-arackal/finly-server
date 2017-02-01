class ItzCash::SetProductCode < ItzCash::Base

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

  def validate
    unless ProductCombination::CODES[params[:product_code_id] - 1].present?
      add_message :error, "Product code does not exist"
    end
  end

  def success
    params[:response_code] = parsed_response[0]
    params[:description] = parsed_response[1]
  end

  class ItzCash::SetProductCode::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :response_code, :serial_id, :applied_product_code, :description

    def init
      self.response_code = params[:response_code]
      self.description = params[:description]
    end
  end


end

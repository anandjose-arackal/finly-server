class Card::Base < BaseOperation

  attr_accessor :card

  def request_params
    return params if params.is_a?(Hash)
    params.require(:card_load_request).permit(:note, amount_attributes: [:value, :currency])
  end


end
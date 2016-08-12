class Card::Base < BaseOperation

  def request_params
    params.require(:card_load_request).permit(:note, amount_attributes: [:value, :currency])
  end

end
class Card::Base < BaseOperation

  attr_accessor :card

  def request_params
    return if params.blank?
    params = self.params
    params = ActionController::Parameters.new(params) if self.params.is_a?(Hash)
    params.require(:card_load_request).permit(:note, amount_attributes: [:id, :value, :currency_id])
  end


end
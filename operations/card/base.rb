class Card::Base < BaseOperation

  attr_accessor :card

  def request_params
    return if params.blank?
    params = self.params
    params = ActionController::Parameters.new(params) if self.params.is_a?(Hash)
    params.require(:money_request).permit(:note, amount_attributes: [:id, :value, :currency_id])
  end


end
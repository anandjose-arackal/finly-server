
class Admin::Cards::Base < Admin::Base
  attr_accessor :card, :company, :created_card

  def card_params
    params.require(:card).permit(:proxy, :ending_number, :user_id, :active, :card_program_id, :itz_cash_card_program_id)
  end

  class Admin::Cards::Base::CardsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :card

    def init
      self.card = params[:card]
    end
  end
end
class Card::Load::Request::Base < Card::Base
  attr_accessor :card_load_request

  def retrieve
    CashLoadRequestPresenter.new(card_load_request)
  end

  class CashLoadRequestPresenter < BaseOperation::BasePresenter
    attr_accessor :card_load_request

    def initialize(card_load_request)
      self.card_load_request = card_load_request
    end
  end

end
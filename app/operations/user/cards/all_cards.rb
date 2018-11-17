class User::Cards::AllCards < User::Cards::Base

  attr_accessor :cards

  class User::Cards::AllCardsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :cards

    def init
      self.cards = params[:cards]
    end
  end

  def pre_validate
    if user.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def process
    self.cards = Card.unscoped.with_user_id(user.id)
  end

  def success
    params[:cards] = self.cards
    User::Cards::AllCardsPresenter.new(user, params, messages)
  end
end
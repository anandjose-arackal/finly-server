class User::Cards::AllCards < User::Cards::Base

  attr_accessor :cards, :selected_user

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

  def init
    id = params[:user_id] || params[:id]
    self.selected_user = current_company.users.find_by(id: id)
    if selected_user.blank?
      self.selected_user = user
    end
  end

  def process
    self.cards = Card.unscoped.with_user_id(self.selected_user.id)
  end

  def success
    params[:cards] = self.cards
    User::Cards::AllCardsPresenter.new(user, params, messages)
  end
end
# operation that lists all the unassigned cards for a particular company as well as the possible card types for a particular user
# parameters:
# params: {
#   company_id: id of the company for which the cards are being queried
#   user_id: id of the user for which the card is being assigned
# }

class Card::Unassigned < Card::Base

  attr_accessor :unassigned_cards, :company

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.company = user.company
  end

  def validate

  end

  def process
    self.unassigned_cards = company.cards.unassigned
  end

  def post_process

  end

  def success
    params[:unassigned_cards] = unassigned_cards
    Card::Unassigned::CardsPresenter.new(user, params, messages)
  end

  class Card::Unassigned::CardsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :unassigned_cards

    def init
      self.unassigned_cards = params[:unassigned_cards]
    end

  end
end
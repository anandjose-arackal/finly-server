class Autocomplete::Cards < BaseOperation

  attr_accessor :company, :cards

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    self.company = user.company
  end

  def validate

  end

  def authorize

  end

  def process
    self.cards = company.cards.unassigned
  end

  def success
    params[:cards] = cards
    Autocomplete::Cards::CardsPresenter.new(user, params, messages)
  end

  class Autocomplete::Cards::CardsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    include HasScope

    has_scope :filter_search

    attr_accessor :cards

    def init
      self.cards = params[:cards]
      self.cards = apply_scopes(cards, params)
    end

  end
end
class Card::Index < Card::Base
  attr_accessor :cards

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.cards = user.company.cards
  end

  def success
    params[:cards] = self.cards
    Card::Index::SuccessPresenter.new(user, params, messages)
  end

  class Card::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :cards, :paginated_cards

    def init
      self.cards = params[:cards]
      if self.cards.present?
        self.paginated_cards = self.cards.paginate(page: params[:page], per_page: 30)
      end
    end
  end

end
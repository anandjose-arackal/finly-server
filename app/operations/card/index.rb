class Card::Index < Card::Base
  attr_accessor :cards

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.params = {} if params.nil?

    if admin_view? and user.company_admin?
      self.cards = user.company.cards
    elsif personal_view?
      self.cards = user.cards
    else
      # For policy admin, manager and finance managers
      user_ids = User::Index.(user, params).team.pluck(:id)
      self.cards = user.company.cards.with_user(user_ids)
    end
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
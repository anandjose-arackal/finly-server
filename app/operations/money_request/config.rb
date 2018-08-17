class MoneyRequest::Config < BaseOperation
  attr_accessor :categories, :cash_pockets, :card

  def pre_validate
    user_present?
  end

  def init
    self.categories = user.company.categories
    self.cash_pockets = user.user_pockets.cash_pockets_only
    self.card = user.cards.first
  end

  def success
    params[:categories] = self.categories
    params[:cash_pockets] = self.cash_pockets
    params[:card] = self.card
    MoneyRequest::Config::SuccessPresenter.new(user, params, messages)
  end

  class MoneyRequest::Config::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories, :cash_pockets, :card

    def init
      self.categories = params[:categories]
      self.cash_pockets = params[:cash_pockets]
      self.card = params[:card]
    end

    def details_for(pocket)
      adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
      {
          id: pocket.id,
          name: pocket.name,
          balance: adapter.balance(display_balance: true),
          base_currency: pocket.base_currency
      }
    end

  end

end
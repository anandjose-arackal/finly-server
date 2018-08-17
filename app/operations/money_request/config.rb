class MoneyRequest::Config < BaseOperation
  attr_accessor :categories, :cash_pockets, :card, :policy, :field_configurations

  def pre_validate
    user_present?
    return if has_errors?
    if params&.dig(:policy_id).blank?
      add_message :error, 'Policy not found'
      return
    end
  end

  def init
    self.categories = user.company.categories.active
    self.cash_pockets = user.user_pockets.cash_pockets_only
    self.card = user.cards.first
    self.policy = user.policies.with_id(params[:policy_id])&.first
    if policy.present?
      self.field_configurations = self.policy.field_configurations
    end
  end

  def validate
    unless self.policy.present?
      add_message :error, 'Policy not found'
      return
    end
  end

  def success
    params[:categories] = self.categories
    params[:cash_pockets] = self.cash_pockets
    params[:card] = self.card
    MoneyRequest::Config::SuccessPresenter.new(user, params, messages)
  end

  class MoneyRequest::Config::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories, :cash_pockets, :card, :field_configurations

    def init
      self.categories = params[:categories]
      self.cash_pockets = params[:cash_pockets]
      self.card = params[:card]
      self.field_configurations = params[:field_configurations]
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
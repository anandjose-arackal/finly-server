class BudgetManager::BudgetsTrb::Contracts::Base < Reform::Form

  property :budget_amount, populate_if_empty: Amount do
    property :value
    property :currency_id
  end

end
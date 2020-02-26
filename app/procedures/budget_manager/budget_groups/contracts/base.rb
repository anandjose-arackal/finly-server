class BudgetManager::BudgetGroups::Contracts::Base < Reform::Form

  properties :name, :purchase_order, :payment, :expense, :purchase_request, :invoice
  property :period_id, validates: {presence: true}
  property :company, validates: {presence: true}
  property :start_date, presence: true
  property :end_date, presence: true
  property :budget_date_type, presence: true

end
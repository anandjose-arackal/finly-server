class BudgetManager::Budgets::Contract::Base < Reform::Form
  include Dry

  properties :name, :start_date, :end_date, :budget_amount, validates: {presence: true}
  property :ancestry
  property :budget_amount do
    property :value, validates: {presence: true}
  end
end
class BudgetManager::BudgetsTrb::Contracts::Base < Reform::Form
  include Dry

  properties :name, :start_date, :end_date, :budget_group_id, validates: {presence: true}
  property :ancestry
  # property :budget_amount, populate_if_empty: Hash do
  #   # include Struct
  #   property :value, presence: true
  #   property :currency_id, default: Currency.first.id
  # end


  # property :budget_amount, populator: :budget_amount_populator! do
  #   property :value, validates: {presence: true}
  # end
end
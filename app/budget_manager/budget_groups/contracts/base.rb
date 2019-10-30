module BudgetGroups::Contract
  class Base < Reform::Form

    properties :name, :purchase_order, :payment, :expense, :purchase_request, :invoice
    property :period, validates: {presence: true}
    property :company, validates: {presence: true}

    collection :budget_group_criteria_mappings do
      property :budget_group_id, presence: true
      property :budgetable_id, presence: true
      property :budgetable_type, presence: true
    end

  end
end
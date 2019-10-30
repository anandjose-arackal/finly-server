module BudgetGroups::Create
  class Create < Reform::Form

    properties :name, :purchase_order, :payment, :expense, :purchase_request, :invoice
    property :period, validates: {presence: true}
    property :company, validates: {presence: true}

    property :budget_group_criteria_mappings do
      property :budget_group
      property :budgetable
    end


  end
end
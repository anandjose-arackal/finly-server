json.result do
  budget_group_criterium = @op["model"]
  json.budget_group_criteria do

    json.budgetable_categories budget_group_criterium.budgetable_categories
    json.budgetable_vendors budget_group_criterium.budgetable_vendors
    json.budgetable_locations budget_group_criterium.budgetable_locations
    json.budgetable_users budget_group_criterium.budgetable_users
    json.budgetable_departments budget_group_criterium.budgetable_departments
    json.budgetable_cost_centers budget_group_criterium.budgetable_cost_centers
    json.name budget_group_criterium.name
    json.id budget_group_criterium.id
    json.period_id budget_group_criterium.budget_group.period_id
    json.period budget_group_criterium.budget_group.period&.name
    json.budget_group_name budget_group_criterium.budget_group&.name
    json.purchase_order budget_group_criterium.budget_group&.purchase_order
    json.invoice budget_group_criterium.budget_group&.invoice
    json.expense budget_group_criterium.budget_group&.expense
    json.purchase_request budget_group_criterium.budget_group&.purchase_request
    json.payment budget_group_criterium.budget_group&.payment
  end
end
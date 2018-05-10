json.array! @result.budgets do |budget|
  json.extract! budget, :id, :name
  json.period do
    json.extract! budget.period, :id, :name
  end

  json.start_date budget.start_date&.strftime("%d-%b-%y")
  json.end_date budget.end_date&.strftime("%d-%b-%y")

  json.budget_amount do
    json.extract! budget.budget_amount, :id, :value, :currency_id
  end

  json.spent_amount 0
  json.associated_item do
    json.id budget.budgetable_id
    json.type budget.budgetable_type
    json.item budget.budgetable
  end

  json.user do
    json.extract! budget.user, :id, :mobile_number, :email
  end
end


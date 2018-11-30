json.root_budgets do
  json.array!(@result.root_budgets) do |budget|
    json.id budget.id
    json.name budget.name
  end
end
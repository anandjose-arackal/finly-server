json.root_budgets do
  json.array!(@result.root_budgets) do |budget|
    json.id budget.id
    json.name budget.name
  end
end

json.all_budgets do
  json.array!(@result.all_budgets) do |budget|
    json.merge! budget.only_name_as_json
  end
end

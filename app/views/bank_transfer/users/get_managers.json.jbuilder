json.managers do
  json.array!(@result.managers) do |manager|
    json.id manager.id
    json.name manager.name
  end
end

json.finance_managers do
  json.array!(@result.finance_managers) do |manager|
    json.id manager.id
    json.name manager.name
  end
end
json.expense_types do
  json.array!(@result) do |et|
    json.id et.id
    json.name et.name
  end
end
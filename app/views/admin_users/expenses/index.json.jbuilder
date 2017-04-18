json.array!(@result.expenses) do |expense|
  json.extract! expense, :amount_value, :date, :merchant_name, :note, :category_name, :id
  json.categories do
    json.array!(@result.categories) do |category|
      json.id category.id
      json.name category.name
    end
  end
end
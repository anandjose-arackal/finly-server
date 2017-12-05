json.categories do
  json.array!(@result.categories) do |category|
    json.id category.id
    json.name category.name
  end
end

json.custom_fields @result.custom_fields
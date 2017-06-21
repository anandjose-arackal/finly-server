json.categories do
  json.array!(@result.categories) do |category|
    json.id category.id
    json.name category.name
  end
end
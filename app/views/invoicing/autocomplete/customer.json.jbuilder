json.array!(@result.customers) do |customer|
  json.label customer.name
  json.value customer.id
end

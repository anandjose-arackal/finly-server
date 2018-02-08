json.array!(@result.customers) do |customer|
  json.id customer.id
  json.name customer.name
  json.mobile_number customer.mobile_number
  json.email customer.email
  json.company do
    json.name customer.company.name
  end
  json.description customer.description
end
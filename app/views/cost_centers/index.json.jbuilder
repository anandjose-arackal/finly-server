json.array!(@result.cost_centers) do |cost_center|
  json.name cost_center.name
  json.id cost_center.id
end
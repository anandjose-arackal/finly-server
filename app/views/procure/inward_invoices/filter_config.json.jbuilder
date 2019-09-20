json.locations do 
  json.array! @result.locations do |location|
    json.merge! location.as_json(tree: true)
  end
end

json.departments do
  json.array! @result.departments do |department|
    json.merge! department.as_json(tree: true)
  end
end

json.cost_centers do
  json.array! @result.cost_centers do |cost_center|
  json.extract! cost_center, :id, :name
  end
end

json.policies do |policy|
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name
  end
end

json.agreement_invoice_enabled @result.agreement_invoice_enabled

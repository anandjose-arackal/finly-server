json.result do
  json.types do
    json.array! @op['result']['types']
  end

  json.policies {json.array! @op['result']['policies']}
  json.departments {json.array! @op['result']['departments']}
  json.cost_centers {json.array! @op['result']['cost_centers']}
  json.locations {json.array! @op['result']['locations']}
end
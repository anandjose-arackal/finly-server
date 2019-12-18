json.result do
  json.array! @op['result']['credit_notes'].as_json(index: true)
end
json.count @op['result']['credit_notes'].count

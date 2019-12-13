json.result do
  json.array! @op['result']['credit_notes']
end
json.count @op['result']['credit_notes'].count

json.result do
  json.array! @op['result']['subscriptions']
end
json.count @op['result']['subscriptions'].count

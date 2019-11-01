json.result do
  json.array! @result['subscriptions']
end
json.count @result['subscriptions'].count

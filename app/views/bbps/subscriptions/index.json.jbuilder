json.result do
  json.array! @op['result']['paginated_subscriptions']
end
json.count @op['result']['subscriptions'].count

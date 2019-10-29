json.result do
  json.array!(@result['subscriptions']) do |subscription|
    json.merge! subscription.as_json
  end
end
json.count @result['subscriptions'].count

json.result do
  json.array! @op['result']['bills']
end
json.count @op['result']['bills'].count

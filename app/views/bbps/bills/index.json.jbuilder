json.result do
  json.array! @op['result']['bills'].as_json({index: true})
end
json.count @op['result']['bills'].count

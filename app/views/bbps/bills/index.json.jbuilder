json.result do
  json.array! @op['result']['paginated_bills'].as_json({index: true})
end
json.count @op['result']['bills'].count

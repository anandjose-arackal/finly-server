json.result do
  json.array! @op['result']
end
json.count @op['result'].count

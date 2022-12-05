json.data do
  json.results @op['model.records']
  json.statuses @op['statuses']
  json.count @op['count']
end
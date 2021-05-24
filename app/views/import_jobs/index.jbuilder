json.data do
  json.array! @op['model.records']
end
json.count @op['model.records'].count

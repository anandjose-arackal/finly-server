json.data do
  json.array! @op['model.records'].each do |record|
    json.id record.id
    json.name record.name
    json.filters record.filters
    json.columns record.columns
  end
end
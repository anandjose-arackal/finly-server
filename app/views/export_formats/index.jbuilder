json.results do
  json.array! @op['model.records'].each do |record|
    json.name record.name
    json.value record.value
  end
end
json.count @op['model.records'].count

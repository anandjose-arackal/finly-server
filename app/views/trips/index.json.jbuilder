json.data do
  json.array! @op['model.records'].each do |record|
    json.id record.id
  end
end
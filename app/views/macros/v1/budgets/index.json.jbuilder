json.data do
  json.array! @op['model.records'] do |record|
    json.partial! 'budget', record: record
  end
end
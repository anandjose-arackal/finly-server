includes = [:payments]
json.data do
  json.array! @op['model.records'].includes(includes)  do |record|
    json.partial! 'bbps_bill', record: record
  end
end
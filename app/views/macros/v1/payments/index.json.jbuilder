includes = [

]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'payment', record: record
  end
end
includes = [

]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'vendor', record: record
  end
end
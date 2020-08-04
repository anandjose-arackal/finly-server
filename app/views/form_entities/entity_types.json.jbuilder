types = @op['model.types']

json.result do

  json.array! types do |type|
    json.name type.first
    json.options type.second.options
  end
end

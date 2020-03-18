model = @op[:model]
json.routes do
  json.array! model.routes
end
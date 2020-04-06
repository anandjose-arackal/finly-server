model = @op[:model]
json.passengers do
  json.array! model.passengers
end
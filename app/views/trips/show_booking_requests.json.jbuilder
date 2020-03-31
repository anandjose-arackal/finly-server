model = @op[:model]
json.transport_requests do
  json.array! model.transport_requests
end
json.hotel_requests do
  json.array! model.hotel_requests
end
json.local_conveyance_requests do
  json.array! model.local_conveyance_requests
end
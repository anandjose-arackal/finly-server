model = @op[:model]
json.created_by model.created_by
json.status do
  json.name model.status.name
end
json.trip_id model.trip_id
json.policy model.policy
json.start_date model.start_date
json.end_date model.end_date
json.purpose model.purpose
json.trip_type_id model.trip_type_id
model.custom_fields.each do |custom_field|
  json.set! custom_field.field_key, custom_field.value
end
json.passengers do
  json.array! model.passengers
end
json.routes do
  json.array! model.routes
end
json.transport_requests do
  json.array! model.transport_requests
end
json.hotel_requests do
  json.array! model.hotel_requests
end
json.local_conveyance_requests do
  json.array! model.local_conveyance_requests
end
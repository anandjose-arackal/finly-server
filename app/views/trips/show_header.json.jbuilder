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
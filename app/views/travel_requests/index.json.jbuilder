json.array!(@result.travel_requests) do |travel_request|
  json.id travel_request.id
  json.utr travel_request.request_number
  json.name travel_request.name
  json.status travel_request.status&.name
  json.user travel_request.user
  json.controlling_user travel_request.controlling_user
  json.dates do
    json.from DateUtils.date_formatted travel_request.from_date
    json.to DateUtils.date_formatted travel_request.to_date
  end
  json.destinations travel_request.destinations
end
json.array!(@result.travel_requests) do |travel_request|
  json.id travel_request.id
  json.name travel_request.name
  json.status travel_request.status&.name&.humanize
  json.user do
    json.id travel_request.user_id
    json.name travel_request.user.name
  end
  json.controlling_user do
    json.id travel_request.controlling_user_id
    json.name travel_request.controlling_user&.name
  end
end
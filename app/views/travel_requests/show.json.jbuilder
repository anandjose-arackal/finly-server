json.travel_request @result.travel_request

json.manager_name @result.manager&.name
json.travel_manager_name @result.travel_manager&.name
json.controlling_user_name @result.travel_request&.controlling_user&.name
json.owner_name @result.travel_request&.user&.name

json.destinations do
  json.array! @result.destinations do |destination|
    json.extract! destination, :id, :location
    json.booking_requests @result.grouped_requests(destination)
  end
end

json.actions @result.actions
json.policies @result.travel_request.user.policies

json.comments do
  json.array!(@result.travel_request.comments) do |comment|
    json.content comment.retrieve_content(current_user)
    json.user_name comment.user&.name
    json.timestamp comment.created_at.strftime('%d %b %Y')
    json.initials comment.user&.initials
  end
end
json.travel_request @result.travel_request

json.manager_name @result.manager&.name
json.travel_manager_name @result.travel_manager&.name
json.controlling_user_name @result.travel_request&.controlling_user&.name
json.owner do
  owner = @result.travel_request.user
  json.first_name owner.first_name
  json.last_name owner.last_name
  json.gender owner.profile.gender
  json.age DateUtils.age(owner.profile.date_of_birth)
  json.salutation owner.profile.salutation_status
end

json.destinations do
  json.array! @result.destinations do |destination|
    json.extract! destination, :id, :location
    json.booking @result.grouped_bookings(destination)
  end
end

json.actions @result.actions
json.policies @result.travel_request.user.policies
json.editable @result.editable
json.destroyable @result.destroyable
json.can_select_options @result.can_select_options?
json.can_add_request @result.can_add_request?
json.can_add_options @result.can_add_options?
json.can_add_booking @result.can_add_booking?
json.can_cancel_booking @result.can_cancel_booking?


json.comments do
  json.array!(@result.travel_request.comments) do |comment|
    json.content comment.retrieve_content(current_user)
    json.user_name comment.user&.name
    json.timestamp comment.created_at.strftime('%d %b %Y')
    json.initials comment.user&.initials
  end
end
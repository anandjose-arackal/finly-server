json.result do
  json.array! @result.paginated_travel_requests.each do |travel_request|
    request_json = travel_request.as_json
    request_json.merge!({status: {id: travel_request.status_id, name: travel_request.status_for_user(@result.user)}})
    request_json.each do |key, value|
      json.set! key, value
    end
    if travel_request.get_reviewers.present?
      json.controlling_user travel_request.get_reviewers.first
    end
  end
end

json.count @result.count

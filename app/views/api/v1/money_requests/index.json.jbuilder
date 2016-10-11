json.array! @result.paginated_money_requests do |money_request|
  json.partial! 'money_request', money_request: money_request
end
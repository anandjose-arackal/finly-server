json.array!(@result.paginated_money_requests) do |money_request|
  json.extract! money_request, :id, :name, :memo, :status_name, :required_by_date
  json.policy money_request.policy.name if money_request.policy
  json.total money_request.total_amount
  json.date money_request.created_at.strftime("%d %b")
end
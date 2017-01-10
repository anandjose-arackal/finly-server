json.array!(@result.paginated_money_requests) do |money_request|
  json.extract! money_request, :id, :name, :memo, :required_by_date
  json.status_name @result.status_name(money_request)
  json.user do
    json.extract! money_request.user,  :name
  end
  json.policy money_request.policy.name if money_request.policy
  json.total(('%.2f' % money_request.total_amount))
  json.date money_request.created_at.strftime("%d %b")
end
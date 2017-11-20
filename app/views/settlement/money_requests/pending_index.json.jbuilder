json.array! @result.paginated_money_requests do |money_request|

  json.extract! money_request, :id, :name
  json.user money_request.user
  json.final_approver money_request.final_approver
  currency = Currency.first
  json.total_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: money_request.total_amount, currency: currency)
  end

end
json.array! @result.paginated_money_requests do |money_request|

  json.extract! money_request, :id, :name, :policy
  json.submitted_on DateUtils.date_formatted money_request.submitted_at
  json.approved_on DateUtils.date_formatted money_request.approved_at
  json.required_by_date DateUtils.date_formatted money_request.required_by_date
  json.user money_request.user
  json.final_approver money_request.final_approver
  currency = Currency.first
  json.total_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: money_request.total_amount, currency: currency)
  end

end
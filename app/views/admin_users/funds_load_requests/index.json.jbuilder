json.array! @result.funds_load_requests do |request|
  json.extract! request, :id, :reference_id, :remark
  json.amount request.amount.value
  json.date request.date.strftime "%d %b %Y"
  json.bank_type request.bank_type.name
  json.company do
    json.name request.company.name
    json.id request.company.id
  end
  json.user do
    json.name request.requested_by_user.name
    json.id request.requested_by_user.id
    json.mobile_number request.requested_by_user.mobile_number
    json.email request.requested_by_user.email
  end
end
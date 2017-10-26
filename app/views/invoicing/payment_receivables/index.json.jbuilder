json.array!(@result.receivables) do |receivable|
  json.amount_value receivable.amount&.value
  json.expire_by receivable.expire_by&.strftime("%d-%m-%Y")
  json.initiating_user receivable.initiating_user&.name
  json.id receivable.id
end
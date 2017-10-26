json.array!(@result.receivables) do |receivable|
  json.amount_value receivable.amount&.value
  json.expire_by receivable.expire_by&.strftime("%d-%m-%Y")
  json.initiating_user receivable.initiating_user&.name
  json.id receivable.id
  json.virtual_account_number receivable.virtual_bank_account&.account_number
  json.ifsc receivable.virtual_bank_account&.ifsc
  json.status receivable.payment_receivable_status&.name
end
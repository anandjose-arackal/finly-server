json.account_number @result.virtual_bank_account.account_number
json.ifsc @result.virtual_bank_account.ifsc
json.amount @result.payment_receivable.amount&.value
json.expire_by @result.payment_receivable.expire_by&.strftime("%m %B, %Y")
json.status @result.payment_receivable.payment_receivable_status&.name&.humanize
json.initiating_user do
  json.name @result.payment_receivable.initiating_user&.name
  json.mobile_number @result.payment_receivable.initiating_user&.mobile_number
end
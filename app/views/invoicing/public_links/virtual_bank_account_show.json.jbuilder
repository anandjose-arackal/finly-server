json.account_number @result.virtual_bank_account.account_number
json.ifsc @result.virtual_bank_account.ifsc
json.company do
  json.name @result.company
  json.logo @result.company.configuration.logo&.url
end
json.amount @result.payment_receivable.amount_value
json.expire_by @result.payment_receivable.expires_by
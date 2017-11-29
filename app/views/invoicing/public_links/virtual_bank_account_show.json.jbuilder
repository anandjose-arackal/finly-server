json.account_number @result.virtual_bank_account.account_number
json.ifsc @result.virtual_bank_account.ifsc
json.company do
  json.name @result.company
  json.logo @result.company.configuration.logo&.url
end

if @result.virtual_bank_account.payment_link?
  json.payment_link true
  json.payment_receivable do
    json.amount @result.virtual_bank_account.parent.amount_value
    json.expire_by @result.virtual_bank_account.parent.expire_by
    json.status @result.virtual_bank_account&.parent&.payment_receivable_status&.name&.humanize
  end
end
json.array!(@result.virtual_accounts) do |virtual_account|
  json.id virtual_account.id
  json.account_number virtual_account.account_number
  json.ifsc virtual_account.ifsc
  json.name virtual_account.name
end
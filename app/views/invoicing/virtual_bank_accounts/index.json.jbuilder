json.array!(@result.virtual_bank_accounts) do |virtual_bank_account|
  json.account_number virtual_bank_account.account_number
  json.ifsc virtual_bank_account.ifsc
  json.expires_by virtual_bank_account.expires_by&.strftime("%d %B, %Y")
  json.initiating_user virtual_bank_account.initiating_user&.name
  json.description virtual_bank_account.description
  json.id virtual_bank_account.id
end
json.array!(@result.bank_accounts) do |bank_account|
  json.account_number bank_account.account_number
  json.ifsc bank_account.ifsc
  json.name bank_account.name
  json.owner_name bank_account.account_owner.name
  json.id bank_account.id
  json.custom_fields_config @result.custom_fields_config
end
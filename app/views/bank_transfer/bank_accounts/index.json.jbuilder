json.array!(@result.bank_accounts) do |bank_account|
  json.account_number bank_account.account_number
  json.id bank_account.id
  json.name bank_account.account_owner.name
  json.ifsc bank_account.ifsc
  json.email bank_account.account_owner.email
  json.mobile_number bank_account.account_owner.mobile_number
  json.owner_id bank_account.account_owner.id
  json.owner_type bank_account.acocunt_owner.class.name
end
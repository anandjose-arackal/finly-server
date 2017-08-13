json.array!(@result.bank_accounts) do |bank_account|
  json.account_number bank_account.account_number
  json.ifsc bank_account.ifsc
  json.name bank_account.account_owner.name
  json.id bank_account.id
end
json.array!(@result.bank_accounts) do |bank_account|
  json.id bank_account.id
  json.name bank_account.name
  json.account_number bank_account.account_number
  json.ifsc bank_account.ifsc
end
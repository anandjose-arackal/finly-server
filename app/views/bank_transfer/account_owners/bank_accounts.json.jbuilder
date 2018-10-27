json.array!(@result.bank_accounts) do |bank_account|
  json.name bank_account.name
  json.account_number bank_account.account_number
  json.ifsc bank_account.ifsc
end
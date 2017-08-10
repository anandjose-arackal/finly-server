json.array!(@result.vendors) do |vendor|
  json.name vendor.name
  json.email vendor.email
  json.mobile_number vendor.mobile_number
  json.bank_accounts do
    json.array!(vendor.bank_accounts) do |bank_account|
      json.account_number bank_account.account_number
      json.ifsc bank_account.ifsc
    end
  end
end
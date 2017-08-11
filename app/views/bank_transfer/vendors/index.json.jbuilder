json.array!(@result.vendors) do |vendor|
  json.id vendor.id
  json.name vendor.name
  json.email vendor.email
  json.mobile_number vendor.mobile_number
  json.bank_accounts do
    json.array!(vendor.bank_accounts) do |bank_account|
      json.account_number bank_account.account_number
      json.ifsc bank_account.ifsc
      json.id bank_account.id
      json.name bank_account.name
    end
  end
end
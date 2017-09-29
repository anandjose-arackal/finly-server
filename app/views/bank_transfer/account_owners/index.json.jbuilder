json.array!(@result.paginated_account_owners) do |vendor|
  json.extract! vendor, :id, :name, :email, :mobile_number

  if vendor.is_a?(YesBankVendor)
    json.description vendor.description
  end

  json.bank_accounts do
    json.array!(vendor.bank_accounts) do |bank_account|
      json.extract! bank_account, :id, :ifsc, :name, :account_number
      json.default bank_account.default_account
    end
  end
end
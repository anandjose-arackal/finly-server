json.array!(@result.paginated_vendors) do |vendor|
  json.extract! vendor, :id, :name, :email, :mobile_number, :description

  json.bank_accounts do
    json.array!(vendor.bank_accounts) do |bank_account|
      json.extract! bank_account, :id, :ifsc, :name, :account_number
      json.default bank_account.default_account
    end
  end
end
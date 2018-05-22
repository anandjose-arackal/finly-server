json.array!(@result.vendors) do |vendor|
  json.label vendor.name
  json.value vendor.id

  json.extract! vendor, :id, :name, :email, :mobile_number

  json.description account_owner.description
  json.created_by account_owner.created_by&.name

  json.bank_accounts do
    json.array!(vendor.bank_accounts.non_deleted) do |bank_account|
      json.extract! bank_account, :id, :ifsc, :name, :account_number
      json.default bank_account.default_account
    end
  end
end
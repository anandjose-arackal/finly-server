json.array!(@result.paginated_account_owners) do |account_owner|
  json.extract! account_owner, :id, :name, :email, :mobile_number

  if account_owner.is_a?(YesBankVendor)
    json.description account_owner.description
    json.beneficiary_type 2
    json.created_by account_owner.created_by&.name
    json.vendor_type_name account_owner.vendor_type&.name
  end

  json.bank_accounts do
    json.array!(account_owner.bank_accounts.non_deleted) do |bank_account|
      json.extract! bank_account, :id, :ifsc, :name, :account_number
      json.default bank_account.default_account
    end
  end
end
json.results do
  json.array!(@result.paginated_account_owners) do |account_owner|
    json.extract! account_owner, :id, :name, :email, :mobile_number

    if account_owner.is_a?(YesBankVendor)
      # display_name = account_owner.business_name || account_owner.name
      # json.display_name display_name
      json.display_name account_owner.name rescue nil
      json.business_name account_owner.business_name rescue nil
      json.vendor_id account_owner.vendor_id
      json.description account_owner.description
      json.beneficiary_type 2
      json.created_by account_owner.created_by&.name
      json.vendor_type_name account_owner.vendor_type&.name
    end

    json.bank_accounts do
      json.array!(account_owner.bank_accounts.non_deleted) do |bank_account|
        json.display_name account_owner.name
        json.extract! bank_account, :id, :ifsc, :name, :account_number
        json.default bank_account.default_account
      end
    end
  end
end

json.count @result.account_owners.count
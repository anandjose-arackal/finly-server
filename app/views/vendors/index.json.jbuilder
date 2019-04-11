json.result do

  json.array!(@result.paginated_vendors) do |vendor|
    json.extract! vendor, :id, :name, :business_name, :description, :vendor_id
    json.vendor_id vendor&.vendor_id
    json.vendor_type vendor.vendor_type.as_json
    json.controlling_user vendor.get_reviewers.first&.name
    json.extract! vendor, :id, :name, :email, :mobile_number
    json.policy vendor.policy.as_json

    json.status vendor.status.as_json

    json.description vendor.description
    json.created_by vendor.created_by&.name
    json.created_at vendor.created_at.strftime "%d %b %y"

    json.bank_accounts do
      json.array!(vendor.bank_accounts.non_deleted) do |bank_account|
        json.extract! bank_account, :id, :ifsc, :name, :account_number
        json.default bank_account.default_account
      end
    end
  end
end

json.count @result.count
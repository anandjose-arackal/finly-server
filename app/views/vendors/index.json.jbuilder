json.result do

  json.array!(@result.paginated_vendors) do |vendor|
    json.label vendor.name
    json.value vendor.id
    json.vendor_id vendor&.vendor_id

    json.extract! vendor, :id, :name, :email, :mobile_number

    json.status vendor.status.as_json

    json.description vendor.description
    json.created_by vendor.created_by&.name

    json.bank_accounts do
      json.array!(vendor.bank_accounts.non_deleted) do |bank_account|
        json.extract! bank_account, :id, :ifsc, :name, :account_number
        json.default bank_account.default_account
      end
    end
  end
end

json.count @result.count
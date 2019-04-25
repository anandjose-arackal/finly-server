json.result do

  json.array!(@result.paginated_vendors) do |vendor|
    # json.can_approve vendor.can_approve?
    json.can_approve vendor.can_really_approve?
    # json.can_reject vendor.can_reject?
    json.can_reject vendor.can_really_reject?
    json.can_take_control vendor.can_take_control?
    json.pan vendor.pan
    # json.gstin vendor.gstin_locations&.pluck(:gstin)
    json.gstin ["07AAACB5343E1Z3","06AAACB5343E1Z5","32AAACB5343E1ZA"]
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
      # json.array!(vendor.bank_accounts.non_deleted) do |bank_account|
      json.array!(vendor.bank_accounts.map {|ba| ba if ba.deleted_at == nil}.compact) do |bank_account|
        json.extract! bank_account, :id, :ifsc, :name, :account_number
        json.default bank_account.default_account
      end
    end
  end
end

json.count @result.count
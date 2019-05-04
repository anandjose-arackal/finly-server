json.account_owner do
  json.extract! @result.account_owner, :id, :name, :email, :mobile_number
  if @result.account_owner.is_a?(YesBankVendor)
    json.payment_term @result.account_owner.payment_term
    json.currency @result.account_owner.currency
    json.business_name @result.account_owner.business_name
    json.address @result.account_owner.address
    json.authorized @result.account_owner.authorized
    json.description @result.account_owner.description
    json.editable_details (@result.user.permission.create_beneficiaries || @result.user.vendor_payments_admin?)
    json.pan @result.account_owner.pan
    json.gst @result.account_owner.gst
    json.tin @result.account_owner.tin
    json.state_code_id @result.account_owner.state_code_id
    json.state_code_name @result.account_owner.state_code&.full_name
    json.created_by @result.account_owner.created_by&.name
    json.vendor_id @result.account_owner.vendor_id
  else
    json.editable_details false
  end
  json.created_at @result.account_owner.created_at.strftime "%b %d %yy"
end
json.id @result.account_owner.id
json.bank_accounts do
  json.array!(@result.bank_accounts) do |bank_account|
    json.account_number bank_account.account_number
    json.ifsc bank_account.ifsc
    json.id bank_account.id
    json.name bank_account.name
    json.default bank_account.default_account
  end
end

if @result.account_owner.is_a?(YesBankVendor)
  json.vendor_type do
    json.id @result.account_owner.vendor_type&.id
    json.name @result.account_owner.vendor_type&.name
  end

end

# json.actions @result.actions

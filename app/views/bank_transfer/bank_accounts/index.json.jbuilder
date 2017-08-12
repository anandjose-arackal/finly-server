json.array!(@result.bank_accounts) do |bank_account|
  json.account do
    json.account_number bank_account.account_number
    json.ifsc bank_account.ifsc
    json.name bank_account.name
    json.id bank_account.id
  end
  json.account_owner do
    json.owner_name bank_account.account_owner.name

    json.email bank_account.account_owner.email
    json.mobile_number bank_account.account_owner.mobile_number
    json.owner_id bank_account.account_owner.id
    json.owner_type bank_account.account_owner.class.name
  end
end
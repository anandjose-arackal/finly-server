json.payments do
  json.array!(@result.bank_accounts) do |bank_account|
    json.account_number bank_account.account_number
    json.ifsc bank_account.ifsc
    json.name bank_account.name
    json.owner_name bank_account.account_owner.name
    json.id bank_account.id
    json.custom_fields_config @result.custom_fields_config
  end
end
json.invoice_categories do
  json.array!(@result.invoice_categories) do |category|
    json.id category.id
    json.name category.name
  end
end
json.invoice_item_categories do
  json.array!(@result.invoice_item_categories) do |category|
    json.id category.id
    json.name category.name
  end
end
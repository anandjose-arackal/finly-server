json.array!(@result.virtual_accounts) do |virtual_account|
  json.id virtual_account.id
  json.account_number virtual_account.account_number
  json.ifsc virtual_account.ifsc
  json.name virtual_account.name

  # Needed customer id in index, do not remote; refer abi
  json.customer_id virtual_account&.customer_id
end
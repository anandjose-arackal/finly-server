json.result do
  json.array!(@result.paginated_virtual_bank_accounts) do |virtual_bank_account|
    json.name virtual_bank_account.name
    json.account_number virtual_bank_account.account_number
    json.ifsc virtual_bank_account.ifsc
    json.expires_by virtual_bank_account.expires_by&.strftime("%d %B, %Y")
    json.initiating_user do
      json.name virtual_bank_account.initiating_user&.name
      json.mobile_number virtual_bank_account.initiating_user&.mobile_number
      json.email virtual_bank_account.initiating_user&.email
    end
    json.transactions do
      payments = virtual_bank_account.initiating_payments
      json.number payments.count
      json.total payments.sum_amounts
    end
    json.description virtual_bank_account.description
    json.id virtual_bank_account.id
  end
end
json.count @result.count
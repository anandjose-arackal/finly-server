json.array! @bank_accounts do |bank_account|
  json.extract! bank_account, :id, :account_number, :ifsc, :name, :address_1, :address_2, :pin_code
end


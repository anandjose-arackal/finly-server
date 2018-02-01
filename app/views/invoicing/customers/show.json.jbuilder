customer = @result.customer
json.details do
  json.extract! customer, :name, :email, :mobile_number, :description, :gst, :pan
end

json.company do
  json.name customer.company&.name
  json.id customer.company&.id
end

json.addresses do
  json.array!(customer.addresses) do |address|
    json.name address.name
    json.city address.city
    json.line_1 address.line_1
    json.line_2 address.line_2
    json.line_3 address.line_3
    json.pin_code address.pin_code
    json.default address.default
    json.id address.id
  end
end

json.virtual_accounts do
  json.array!(customer.virtual_bank_accounts) do |virtual_account|
    json.account_number virtual_account.account_number
    json.ifsc virtual_account.ifsc
    json.id virtual_account.id
    json.name virtual_account.name
  end
end
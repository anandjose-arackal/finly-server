customer = @result.customer
json.details do
  json.extract! customer, :id, :name, :email, :mobile_number, :description, :pan
  json.gstin customer.gst
end

json.company do
  json.name customer.company&.name
  json.id customer.company&.id
end

json.created_by customer.created_by&.name

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
    json.landmark address.landmark
    json.state_id address.state_id
    json.state_name address.state&.name
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
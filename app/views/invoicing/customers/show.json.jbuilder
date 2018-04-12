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

json.customer_account do
  json.balance customer.customer_account.balance.amount_value
  json.currency do
    json.id customer.customer_account&.balance&.currency&.id
    json.country customer.customer_account&.balance&.currency&.country
    json.country_code customer.customer_account&.balance&.currency&.country_code
    json.symbol customer.customer_account&.balance&.currency&.symbol
  end

  customer_account_transactions = customer.customer_account.customer_account_transactions
  json.transactions do
    json.array! customer_account_transactions do |cat|
      json.extract! cat, :id, :transaction_type, :associated_object_type
      if cat.associated_object_type == 'OutwardInvoice'
        json.associated_object_id cat.associated_object_id
      elsif cat.associated_object_type == 'VirtualAccountTransaction'
        json.associated_object_id cat.associated_object.virtual_account.id
      end
      json.time cat.created_at.strftime("%I:%M %p")
      json.date cat.created_at.strftime("%d %b %Y")
      json.amount cat.transaction_amount.value
      currency = cat.transaction_amount.currency
      json.currency do
        json.id currency&.id
        json.country currency&.country
        json.country_code currency&.country_code
        json.symbol currency&.symbol
      end
    end
  end
end
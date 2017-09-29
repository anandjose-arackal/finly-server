json.vendor do
  json.extract! @result.vendor, :id, :name, :email, :mobile_number, :authorized, :description
  json.created_at @result.vendor.created_at.strftime "%b %d %yy"
end
json.id @result.vendor.id
json.bank_accounts do
  json.array!(@result.bank_accounts) do |bank_account|
    json.account_number bank_account.account_number
    json.ifsc bank_account.ifsc
    json.id bank_account.id
    json.name bank_account.name
    json.default bank_account.default_account
  end
end
json.transactions do
  json.array!(@result.receiving_transactions) do |payment|
    json.extract! payment, :id, :note, :payment_mode, :reference_id
    json.amount payment.amount.value
    json.date payment.date
    json.payment_order_id payment.payment_order_id
    json.payment
  end
end


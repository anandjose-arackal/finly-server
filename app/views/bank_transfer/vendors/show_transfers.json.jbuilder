json.account_owner do
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
    json.extract! payment, :id, :note, :payment_mode
    json.reference_id payment.utr
    json.amount payment.amount&.value
    json.date payment.date
    json.payment_order_id payment.payment_order&.bank_payment_request.id
    json.payment_mode payment.payment_mode
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.initiating_user_name payment.initiating_user&.name
    json.payment_status payment.payment_status_name
  end
end


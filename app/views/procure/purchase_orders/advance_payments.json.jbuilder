json.array!(@result.advance_payments) do |payment|
  json.account_details do
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
  end
  json.date payment.date
  json.amount payment.amount_value
  json.payment_mode payment.payment_mode
end
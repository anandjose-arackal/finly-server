json.array!(@result.result) do |payment_request|
  json.id payment_request[:id]
  json.name payment_request[:name]
  json.allowed payment_request[:allowed]
  json.next_date payment_request[:next_date]
  json.total_amount payment_request[:total_amount]
  json.created_at payment_request[:created_at]
  json.errors payment_request[:errors]
  json.selectable payment_request[:selectable]
  json.payments do
    json.array!(payment_request[:payment_request].payment_order.payments) do |payment|
      json.beneficiary_account_number payment.receiving_account.account_number
      json.ifsc payment.receiving_account.ifsc
      json.name payment.receiving_user&.name
      json.amount payment.amount_value
    end
  end
end
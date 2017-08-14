json.array!(@result.payments) do |payment|
  json.account_number payment.receiving_account&.account_number
  json.name payment.receiving_user&.name
  json.ifsc payment.receiving_account&.ifsc
  json.amount payment.amount_value
  json.scheduled_date payment.payment_order&.scheduled_at&.strftime("%Y-%m-%d")
  json.processed_date payment.payment_order&.processed_at&.strftime("%Y-%m-%d")
  json.status payment.payment_status&.name
  json.initiating_user payment.initiating_user&.name
end
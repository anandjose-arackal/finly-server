json.array!(@result.credit_payments) do |payment|
  json.date payment.date.strftime("%Y-%m-%d")
  json.initiated_by payment.initiating_resource&.name
  json.received_by payment.receiving_account&.name
  json.account_number payment.receiving_account&.account_number
  json.ifsc payment.receiving_account&.ifsc
  json.amount payment.amount_value
  json.status payment.payment_status&.name&.humanize
  json.system_messages do
    json.array! (payment.system_messages)
  end
end
payment = @result.payment
json.name payment.receiving_account&.name
json.account_number payment.receiving_account.account_number
json.ifsc payment.receiving_account.ifsc
json.invoice_amount precision_value payment.invoice_amount
json.net_amount precision_value payment.amount_value
json.status payment.payment_status_name
json.id payment.id
json.note payment.note
json.payment_mode payment.payment_mode
json.system_messages do
  json.array! (payment.system_messages)
end
json.bank_reference_number payment.reference_resource&.bank_reference_number
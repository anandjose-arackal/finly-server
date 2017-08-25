bank_payment_request = @result.bank_payment_request
payment_order = @result.payment_order
json.summary do
  json.order_status_id bank_payment_request.status.name.humanize
  json.bank_transfer_type payment_order.payment_mode
  json.payment_type payment_order.payment_type.humanize
  json.scheduled_at payment_order.scheduled_at
  json.processed_at payment_order.processed_at
  json.amount_requested payment_order.amount_requested_value
  json.amount_processed payment_order.amount_processed_value
  json.description bank_payment_request.description
  json.note payment_order.note
end

json.payments do
  payment_order.payments.each do |payment|
    json.name payment.receiving_user.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.amount payment.amount_value
    json.status payment.payment_status.name
    json.id payment.id
  end
end

json.attachments do
  payment_order.attachments.each do |attachment|
    json.url attachment.attached_file.url
    json.thumb attachment.attached_file.url(:thumb)
    json.description attachment.description
  end
end

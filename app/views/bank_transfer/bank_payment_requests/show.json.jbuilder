
json.summary do
  json.order_status_id @result.bank_payment_request.status.name.humanize
  json.bank_transfer_type @result.payment_order.payment_mode
  json.payment_type @result.payment_order.payment_type.humanize
  json.scheduled_at @result.payment_order.scheduled_at
  json.processed_at @result.payment_order.processed_at
  json.amount_requested @result.payment_order.amount_requested&.value
  json.amount_processed @result.payment_order.amount_processed&.value
  json.description @result.bank_payment_request.description
  json.note @result.payment_order.note
end

json.payments do
  json.array!(@result.payment_order.payments) do |payment|
    json.name payment.receiving_user.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.amount payment.amount_value
    json.status payment.payment_status.name
    json.id payment.id
  end
end

json.attachments do
  json.array!(@result.payment_order.payment_order_attachments) do |attachment|
    json.url attachment.attached_file.url
    json.thumb attachment.attached_file.url(:thumb)
    json.description attachment.description
  end
end

json.array! @result.payment_requests.each do |payment_request|
  item = payment_request.payment_order
  json.id item.bank_payment_request&.id
  scheduled_at = item.scheduled_at
  if scheduled_at.present?
    scheduled_at = scheduled_at.strftime('%d %b %Y')
  end
  json.name payment_request.name
  json.scheduled_at scheduled_at
  processed_date = item.processed_at
  if processed_date.present?
    processed_date = processed_date.strftime('%d %b %Y')
  end
  json.processed_at processed_date
  json.initiating_user do
    json.name item.initiating_user.name
    json.email item.initiating_user.email
    json.mobile_number item.initiating_user.mobile_number
  end
  json.note item.note
  json.items_count item.payments.count
  json.payment_order_status do
    json.id item.payment_order_status.id
    json.name item.payment_order_status.name.humanize
    json.identifier item.bank_payment_request&.status_name(current_user.id)
  end
  json.amount_processed item.amount_processed
  json.amount_requested item.amount_requested
end
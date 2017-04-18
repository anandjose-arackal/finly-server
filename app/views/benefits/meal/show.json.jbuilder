json.data do
  payment_order = @result.payment_order

  scheduled_at = payment_order.scheduled_at
  if scheduled_at.present?
    scheduled_at = scheduled_at.strftime('%d %b %Y')
  end
  json.scheduled_at scheduled_at
  processed_date = payment_order.processed_at
  if processed_date.present?
    processed_date = processed_date.strftime('%d %b %Y')
  end
  json.processed_at processed_date
  json.initiating_user do
    json.name payment_order.initiating_user.name
    json.email payment_order.initiating_user.email
    json.mobile_number payment_order.initiating_user.mobile_number
  end
  json.note payment_order.note
  json.payment_orders_count payment_order.payments.count
  json.payment_order_status do
    json.id payment_order.payment_order_status.id
    json.name payment_order.payment_order_status.name.humanize
  end
  json.amount_processed payment_order.amount_processed
  json.amount_requested payment_order.amount_requested

  json.payment_items do
    json.array! payment_order.payments.each do |payment|
      json.amount payment.amount
      json.date payment.date
      json.receiving_user do
        json.name payment.receiving_user.name
        json.email payment.receiving_user.email
        json.mobile_number payment.receiving_user.mobile_number
      end
      json.note payment.note
      json.initiating_account payment.initiating_account_type_name
      json.receiving_account payment.receiving_account_type_name
      json.status do
        json.id payment.payment_status.id
        json.name payment.payment_status.name.humanize
      end
    end
  end

  json.actions @result.actions
end
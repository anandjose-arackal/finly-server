json.array! @result.payment_orders.each do |item|
  scheduled_at = item.scheduled_at
  if scheduled_at.present?
    scheduled_at = scheduled_at.strftime('%d %b %Y')
  end
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
  end
  if item.amount_processed.present?
    json.amount_processed do
      json.value item.amount_processed.value
      json.currency do
        json.extract! Currency.first, :id, :country, :country_code, :symbol
      end
    end
  else
    json.amount_processed nil
  end
  if item.amount_requested.present?
    json.amount_requested do
      json.value item.amount_requested.value
      json.currency do
        json.extract! Currency.first, :id, :country, :country_code, :symbol
      end
    end
  else
    json.amount_requested nil
  end
end
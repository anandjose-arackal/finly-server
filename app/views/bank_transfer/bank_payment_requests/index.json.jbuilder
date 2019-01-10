json.count @result.payment_requests.count
json.results do
  json.array! @result.paginated_requests.include_for_index.each do |payment_request|
    item = payment_request.payment_order
    json.id payment_request&.id
    scheduled_at = item.scheduled_at
    if scheduled_at.present?
      scheduled_at = scheduled_at.strftime('%d %b %Y')
    end
    json.name payment_request.name
    json.scheduled_at scheduled_at
    json.controlling_user payment_request.controlling_user&.name
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
    json.items_count item.payments.size
    json.payment_order_status do
      json.id item.payment_order_status.id
      json.name item.payment_order_status.name.humanize
      json.identifier payment_request&.status_name(current_user.id)
    end
    json.amount_processed do
      json.value precision_value item.amount_processed&.value
      json.currency item.amount_processed&.currency
    end
    json.amount_requested do
      json.value precision_value item.amount_requested&.value
      json.currency item.amount_requested&.currency
    end
    json.payment_file_downloaded payment_request.payment_file_downloaded

    json.payments_count payment_request.payment_order.payments.count

    payments = payment_request.payment_order.payments[0..4]
    json.payments do
      json.array!(payments) do |payment|
        json.id payment.id
        json.beneficiary_name payment.receiving_account&.account_owner&.name
        json.payment_mode payment.payment_mode&.upcase
        json.date payment.date.strftime('%d %b %Y')
        json.amount payment.amount_value
        json.utr payment.reference_resource&.bank_reference_number
        json.payment_status payment.payment_status_name
      end
    end
  end
end
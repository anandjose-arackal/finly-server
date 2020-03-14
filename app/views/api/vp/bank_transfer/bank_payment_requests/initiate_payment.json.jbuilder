json.summary do
  json.order_status do
    json.name @result.bank_payment_request.status_name(current_user.id)&.humanize
    json.identifier @result.bank_payment_request.status_name(current_user.id)
  end
  json.policy do
    json.id @result.bank_payment_request.policy&.id
    json.name @result.bank_payment_request.policy&.name
  end
  # json.retriable @result.bank_payment_request.retriable?
  json.bank_transfer_type @result.payment_order.payment_mode&.upcase
  json.payment_type @result.payment_order.payment_type&.humanize
  json.scheduled_at @result.payment_order.scheduled_at&.strftime "%d %b %Y"
  json.processed_at @result.payment_order.processed_at&.strftime "%d %b %Y"
  json.amount_requested precision_value @result.payment_order.amount_requested&.value
  json.amount_processed precision_value @result.payment_order.amount_processed&.value
  json.description @result.bank_payment_request.description
  json.note @result.payment_order.note
  json.initiating_user @result.bank_payment_request.owner.name
  json.name @result.bank_payment_request.name
end

json.payments do
  json.array!(@result.payment_order.payments) do |payment|
    json.owner_name payment.receiving_account&.account_owner&.name
    json.name payment.receiving_account&.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.net_amount precision_value payment.amount_value
    json.status payment.payment_status_name
    json.id payment.id
    json.note payment.note
    json.system_messages do
      json.array! (payment.system_messages)
    end
    json.payment_mode payment.payment_mode
    json.bank_reference_number payment.utr
  end
end

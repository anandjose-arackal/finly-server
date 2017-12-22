json.array! @result.paginated_payments.each do |payment|
  json.payment_order do
    json.id payment.payment_order.id
  end
  json.amount payment.amount
  json.date payment.date
  json.scheduled_date payment.payment_order&.scheduled_at&.strftime("%Y-%m-%d")
  json.processed_date payment.payment_order&.processed_at&.strftime("%Y-%m-%d")
  json.initiating_user do
    json.name payment.initiating_user&.name
    json.email payment.initiating_user.email
    json.mobile_number payment.initiating_user.mobile_number
  end
  json.receiving_user do
    json.name payment.receiving_account.account_owner.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
  end
  json.note payment.note
  json.initiating_account payment.initiating_account_type_name
  json.receiving_account payment.receiving_account_type_name
  json.payment_type payment.payment_type&.name
  json.status do
    json.id payment.payment_status.id
    json.name payment.payment_status_name
  end
  json.bank_reference_number payment.reference_resource&.bank_reference_number
  json.system_messages do
    json.array! (payment.system_messages)
  end
end
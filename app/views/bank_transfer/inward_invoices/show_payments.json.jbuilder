json.array!(@result.payments) do |payment|
  json.receiving_account_name payment.receiving_account&.name
  json.amount payment.amount_value
  json.payment_mode payment.payment_mode&.upcase
  json.id payment.id
  json.order_id payment.payment_order&.bank_payment_request&.id
  json.note payment.note
  if payment.receiving_account.is_a?(BankAccount)
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.utr payment.utr
  end
  json.date payment.date.strftime("%d %B %Y")
  json.payment_status payment.payment_status&.name&.humanize
end
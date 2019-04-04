json.result do
  json.array!(@result.paginated_transactions) do |payment|
    json.extract! payment, :id, :note
    json.reference_id payment.reference_resource&.bank_reference_number
    json.amount payment.amount.value
    json.date payment.date
    json.bank_payment_request_id payment.payment_order&.bank_payment_request&.id
    json.payment_mode payment.payment_mode&.upcase
    json.account_number payment.receiving_account&.account_number
    json.ifsc payment.receiving_account&.ifsc
    json.initiating_user_name payment.initiating_user&.name
    json.payment_status payment.payment_status_name
  end
end

json.count @result.transactions.count
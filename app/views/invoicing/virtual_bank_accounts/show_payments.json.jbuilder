json.transactions do
  json.array!(@result.payments) do |payment|
    json.source_account do
      virtual_trans = payment.virtual_account_transaction
      json.name virtual_trans&.remitter_full_name
      json.ifsc virtual_trans&.remitter_account_ifsc
      json.account_number virtual_trans&.remitter_account_no
    end
    json.amount payment.amount_value
    json.note payment.virtual_account_transaction&.note
    json.date payment.date
  end
end
json.summary do
  json.number @result.payments.count
  json.total @result.payments.sum_amounts
end
json.array!(@result.transactions) do |payment|
  json.source_account do
    virtual_trans = payment.reference_resource
    json.name virtual_trans&.remitter_full_name
    json.ifsc virtual_trans&.remitter_account_ifsc
    json.account_number virtual_trans&.remitter_account_no
  end
  json.amount payment.amount_value
  json.note payment.reference_resource&.note
  json.date payment.date
end

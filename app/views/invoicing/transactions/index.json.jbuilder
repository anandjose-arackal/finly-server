json.array!(@result.incoming_payments) do |payment|
  virtual_trans = payment.reference_resource
  json.source_account do
    json.name virtual_trans&.remitter_full_name
    json.ifsc virtual_trans&.remitter_account_ifsc
    json.account_number virtual_trans&.remitter_account_no
  end
  json.amount payment.amount_value
  json.note payment.reference_resource&.note
  json.date payment.date
  json.virtual_account do
    json.account_number virtual_trans&.virtual_account&.account_number
    json.ifsc virtual_trans&.virtual_account&.ifsc
    json.name virtual_trans&.virtual_account&.name
  end
  json.purpose virtual_trans&.virtual_account&.purpose&.name&.humanize
  if virtual_trans&.virtual_account&.purpose_id == VirtualAccountPurpose.id_for(:invoice)
    json.invoice_id virtual_trans&.invoices&.first&.id # todo - jugaad for now, need to be generalized to include multiple invoices
  end
end
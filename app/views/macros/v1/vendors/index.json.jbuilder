includes = [
    :vendor_type, :payment_term, :policy, :tds_rates, {locations: :state},
    :bank_accounts, :vendor_attachments, {custom_fields: :field_configuration}
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'vendor', record: record
  end
end
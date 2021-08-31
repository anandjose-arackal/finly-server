includes = [
    :vendor_type, :created_by, :payment_term, :policy, :tds_rates, {gstin_locations: :state},
    :bank_accounts, :vendor_attachments, {custom_fields: :field_configuration},
    {dlrms: [:level, :action, :action_taken_by]},
    {custom_fields: :field_configuration},
    {form_custom_fields: [:form_entity, selections: :form_entity_choice]}
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'vendor', record: record
  end
end
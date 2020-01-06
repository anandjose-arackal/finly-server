json.custom_fields do
  # json.array!(@result.field_configurations, :field_name, :id, :field_type, :drop_down_items)
  json.array!(@field_configurations) do |fc|
    json.field_name fc.field_name
    json.id fc.id
    json.field_type fc.field_type
    json.field_key fc.field_key
    case fc.field_type_id
      when FieldType.id_for(:drop_down)
        json.drop_down_items fc.drop_down_items
      when FieldType.id_for(:multiselect)
        json.drop_down_items fc.multiselect_items
      else
        # do nothing?
    end
  end
end

json.policies do
  json.array!(@policies) do |policy|
    json.id policy.id
    json.name policy.name
  end
end

json.show_payment_file_download current_company.payment_file_configuration.present?
json.transfer_modes @transfer_modes.as_json
json.ticket_type BankPaymentRequest.ticket_types.keys
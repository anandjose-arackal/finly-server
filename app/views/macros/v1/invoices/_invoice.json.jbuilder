json.partial! 'invoice_header', record: record
custom_fields = {}
record.custom_fields.each do |custom_field|
  custom_fields[custom_field.field_configuration.field_name] = custom_field.configured_field_value
end
json.custom_fields custom_fields
json.approval_workflow record.dlrms do |dlrm|
  json.partial! 'macros/v1/shared/approval_workflow', dlrm: dlrm
end

json.form_custom_fields do
  json.array! record.form_custom_fields.each do |form_custom_field|
    json.name form_custom_field.form_entity&.label
    json.field_key form_custom_field.field_key
    json.field_value form_custom_field.retrieve_text_value
  end
end

json.line_items do
  json.array! record.items do |item|
    json.id item.id
    json.item_type item.inventory_line_item&.supply_item_type&.name
    json.item_expense_type item.inventory_line_item&.item_expense_type&.name
    json.product_type item.inventory_line_item&.product_type&.name
    json.item_code item.inventory_line_item&.item_number
    json.description item.description
    json.comment item.comment
    json.category item.category
    json.department item.department
    json.cost_center item.cost_center
    json.hsn_sac item.hsn_sac
    json.tds_applicable item.tds_applicable
    json.unit_of_measurement item.unit_of_measurement
    json.quantity item.quantity
    json.rate item.rate
    json.gross_amount item.amount&.value
    json.discount item.discount
    json.discount_amount item.discount_amount&.value
    json.taxable_amount item.taxable_amount&.value
    json.tax_rate item.tax_rate
    json.tax_amount item.tax_amount&.value
    json.net_amount item.net_amount&.value
    json.item_form_custom_fields do
      json.array! item.form_custom_fields.each do |form_custom_field|
        json.name form_custom_field.form_entity&.label
        json.field_key form_custom_field.field_key
        json.field_value form_custom_field.retrieve_text_value
      end
    end
  end
end
json.attachments do
  json.array! record.attachments.reject {|attachment| attachment.file_file_size.nil?} do |attachment|
    json.extract! attachment, :description
    json.file_name attachment.file_file_name
    json.file_size attachment.file_file_size
    json.url attachment.file.url(:original, timestamp: false)
    json.content_type attachment&.file_content_type
  end
end
json.comments do
  json.array! record.comments do |comment|
    json.user comment.user&.as_json
    json.user_name comment.user&.name
    json.body comment.body
    json.commented_at comment.created_at
  end
end
json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at

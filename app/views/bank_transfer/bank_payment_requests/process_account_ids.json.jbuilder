json.payment do
  json.items do
    json.array! @result.processed_order.each do |item|
      json.bank_account_number item[:bank_account_no]
      json.original_amount item[:original_amount]
      json.ifsc item[:ifsc]
      json.name item[:name]
      json.note item[:note]
      json.gst_type_id item[:gst_type_id]
      json.tax_type_id item[:tax_type_id]
      json.tax item[:tax]
      json.discount item[:discount]
      json.tds item[:tds]
      json.tds_type_id item[:tds_type_id]
      json.discount_type_id item[:discount_type_id]
      json.invoice_number item[:invoice_number]
      json.invoice_date item[:invoice_date]
      json.due_date item[:due_date]
      json.inclusive_of_taxes item[:inclusive_of_taxes]
      json.valid item[:valid]
      json.messages item[:messages]
      json.custom_fields_config item[:custom_fields]
    end
  end
  json.errors @result.errors
  json.description @result.description
  json.payment_order_valid @result.payment_order_valid
  json.requested_amount @result.requested_amount
  json.processable_amount @result.processable_amount
  json.scheduled_at @result.scheduled_at_formatted
  json.created_at @result.created_at_formatted
  json.policy_id @result.policy_id
  json.beneficiary_editable false
end
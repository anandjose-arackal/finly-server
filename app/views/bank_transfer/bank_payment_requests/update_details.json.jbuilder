json.payment do
  json.items do
    json.array! @result.processed_order.each do |item|
      json.bank_account_number item[:bank_account_no]
      json.original_amount item[:original_amount]
      json.ifsc item[:ifsc]
      json.name item[:name]
      json.note item[:note]
      json.gst_type_id item[:gst_type_id]
      json.tax_amount item[:tax_amount]
      json.tax item[:tax]
      json.discount item[:discount]
      json.tds item[:tds]
      json.tds_amount item[:tds_amount]
      json.discount_amount item[:discount_amount]
      json.advance item[:advance]
      json.advance_amount item[:advance_amount]
      json.freight item[:freight]
      json.invoice_number item[:invoice_number]
      json.invoice_date item[:invoice_date]
      json.due_date item[:due_date]
      json.inclusive_of_taxes item[:inclusive_of_taxes]
      json.valid item[:valid]
      json.messages item[:messages]
      json.custom_fields_config item[:custom_fields]
      json.net_amount item[:net_amount]
      json.invoice_items do
        json.array!(item[:invoice_items]) do |line_item|
          json.discount line_item[:discount]
          json.tax line_item[:tax]
          json.tax_amount line_item[:tax_amount]
          json.discount_amount line_item[:discount_amount]
          json.description line_item[:description]
          json.category_id line_item[:category_id]
          json.amount line_item[:amount]
          json.rate line_item[:rate]
          json.quantity line_item[:quantity]
          json.gst_type_id line_item[:item_gst_type]
          json.total_amount line_item[:total_amount]
          json.hsn_sac line_item[:hsn_sac]
        end
      end
    end
  end
  json.invoice_categories do
    json.array!(current_company.categories.with_purpose(Purpose.id_for(:invoice))) do |category|
      json.id category.id
      json.name category.name
    end
  end
  json.invoice_item_categories do
    json.array!(current_company.categories.with_purpose(Purpose.id_for(:invoice_items))) do |category|
      json.id category.id
      json.name category.name
    end
  end
  json.errors @result.errors
  json.description @result.description
  json.payment_order_valid @result.payment_order_valid
  json.requested_amount @result.requested_amount
  json.processable_amount @result.processable_amount
  json.scheduled_at @result.scheduled_at_formatted
  json.created_at @result.created_at_formatted
end
json.payment do
  json.items do
    json.array! @result.processed_order.each do |item|
      json.bank_account_number item[:bank_account_no]
      json.original_amount item[:original_amount]
      json.id item[:id]
      json.ifsc item[:ifsc]
      json.name item[:name]
      json.owner_name item[:owner_name]
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
      json.category_id item[:category_id]
      json.cost_center_id item[:cost_center_id]
      json.department_id item[:department_id]
      json.tds_slab_id item[:tds_slab_id]
      json.roundoff_amount item[:roundoff_amount]
      json.balance_due item[:balance_due]
      json.item_taxes_total item[:item_taxes_total]
      json.item_discounts_total item[:item_discounts_total]
      json.items_net_total item[:items_net_total]
      json.item_amounts_total item[:item_amounts_total]
      json.invoice_type_id item[:invoice_type_id]
      json.invoice_type_name item[:invoice_type_name]
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
    json.array!(current_company.categories.vendor_payments_only) do |category|
      json.id category.id
      json.name category.name
    end
  end
  json.invoice_line_items_categories do
    json.array!(current_company.categories.inward_invoice_items_only) do |category|
      json.id category.id
      json.name category.name
    end
  end
  json.cost_centers do
    json.array!(current_company.cost_centers.with_application(RequestStoreUtil.current_app)) do |cost_center|
      json.id cost_center.id
      json.name cost_center.name
    end
  end
  json.tds_slabs do
    json.array!(current_company.tds_slabs) do |tds_slab|
      json.id tds_slab.id
      json.name "#{tds_slab.tds}% - #{tds_slab.name} "
      json.tds tds_slab.tds
    end
  end
  json.departments do
    json.array!(current_company.departments) do |department|
      json.id department.id
      json.name department.name
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
  json.beneficiary_editable true
end
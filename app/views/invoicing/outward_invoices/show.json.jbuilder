invoice = @result.invoice
json.customer do
  json.id invoice.customer&.id
  json.name invoice.customer&.name
  json.gstin invoice.customer&.gst
end

json.invoice do
  json.invoice_number invoice.invoice_number || @result.invoice_number
  json.created_at invoice.created_at
  json.date invoice.date
  json.due_date invoice.due_date
  json.memo invoice.memo
  json.customer_memo invoice.customer_memo
  json.status do
    json.id invoice.invoice_status&.id
    json.name invoice.invoice_status&.name&.humanize
    json.bs_class ""
  end

  if invoice.payment_term
    json.payment_term do
      json.extract! invoice.payment_term, :id, :name, :description, :default
      json.days_after invoice.payment_term&.days_after
    end
  end


  json.invoice_amounts do
    json.item_amounts_total invoice.line_items_total
    json.item_net_amounts_total invoice.line_items_net_total
    json.discount_amount invoice.discount_amount&.value
    json.tax_amount invoice.tax_amount&.value
    json.gst_type_id invoice.gst_type_id
    json.freight_amount invoice.freight_amount&.value
    json.advance_amount invoice.advance_amount&.value
    json.net_total invoice.net_amount&.value
    json.inclusive_of_taxes invoice.inclusive_of_taxes
    json.roundoff_amount invoice.roundoff_amount
    json.balance_due invoice.balance_due&.value
    json.paid_amount invoice.paid_amount&.value
    json.total_payable invoice.total_payable&.value
    json.roundoff_total_enabled invoice.roundoff_total_enabled
  end

  json.invoice_items do
    json.array!(invoice.invoice_items) do |item|
      json.rate item.rate
      json.quantity item.quantity
      json.tax item.tax
      json.discount item.discount
      json.category_id item.category_id
      json.tax_amount precision_value item.tax_amount&.value
      json.discount_amount precision_value item.discount_amount&.value
      json.amount precision_value item.amount&.value
      json.category_name item.category&.name
      json.id item.id
      json.description item.description
      json.total_amount precision_value item.net_amount&.value
      json.hsn_sac item.hsn_sac
      json.inventory_item_id item.inventory_line_item_id
    end
  end

  json.customer do
    json.id invoice.customer&.id
    json.email invoice.email
    json.mobile_number invoice.mobile_number
    json.address_billing invoice.billing_address
    json.address_shipping invoice.shipping_address
  end

  json.virtual_account do
    json.enabled true
    json.account_name invoice.virtual_account&.name
    json.ifsc invoice.virtual_account&.ifsc
    json.account_number invoice.virtual_account&.account_number
    json.id invoice.virtual_account&.id
    json.name invoice.virtual_account&.name
  end

  json.invoice_items_categories do
    json.array!(current_company.categories.outward_invoice_items_categories.active) do |category|
      json.id category.id
      json.name category.name
    end
  end
end

json.actions do
  json.editable invoice.editable?
  json.navbar @result.navbar_actions
end

json.payment_terms do
  json.array! @result.payment_terms do |payment_term|
    json.extract! payment_term, :id, :name, :days_after, :description, :default
  end
end
json.attachment do
  json.array! @result.invoice_attachments do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.attachment_file_name
    json.file_size (attachment.attachment_file_size / 1024).round(2).to_s + " KB"
  end
end


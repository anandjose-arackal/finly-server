invoice = @result.invoice

json.actions do
  json.editable invoice.unpaid?
  json.destroyable invoice.unpaid?
end

json.invoice do
  # conditionally set the original amount as invoice amount is there are line items
  json.id invoice.id
  json.procurement_id invoice.procurement_id
  if invoice&.invoice_items.present?
    json.original_amount precision_value invoice.amount&.value
  else
    json.original_amount precision_value invoice.original_amount&.value
  end
  json.raw_amount precision_value invoice&.amount&.value
  json.advance_amount precision_value invoice.advance_amount&.value
  json.tax_amount precision_value invoice.tax_amount&.value
  json.tds_amount precision_value invoice.tds_amount&.value
  json.tax precision_value invoice.tax
  json.tds precision_value invoice.tds
  json.gst_type_id invoice.gst_type_id
  json.discount_amount precision_value invoice.discount_amount&.value
  json.discount precision_value invoice.discount
  json.advance invoice.advance
  json.freight_amount invoice.freight_amount&.value
  json.date invoice.date
  json.due_date invoice.due_date
  json.invoice_number invoice.invoice_number
  json.inclusive_of_taxes invoice.inclusive_of_taxes
  json.freight_amount invoice.freight_amount&.value
  json.roundoff_amount invoice.roundoff_amount
  json.balance_due invoice.balance_due&.value
  json.taxable_amount precision_value invoice.gross_amount&.value
  # adding the respective rates
  json.tax_rate precision_value invoice.tax_rate
  json.tds_rate precision_value invoice.tds_rate
  json.discount_rate precision_value invoice.discount_rate
  json.advance_rate precision_value invoice.advance_rate
  #############################
  json.invoice_attachment do
    json.url invoice.invoice_attachments.first&.attached_file&.url(:original, timestamp: false)
    json.thumb invoice.invoice_attachments.first&.attached_file&.url(:thumb)
    json.content_type invoice.invoice_attachments.first&.attached_file&.content_type
    json.file_name invoice.invoice_attachments.first&.attached_file&.original_filename
  end
  json.net_amount precision_value invoice.net_amount&.value
  json.gross_amount precision_value invoice.gross_amount&.value
  json.custom_fields do
    json.array! invoice.custom_fields
  end
  json.category_id invoice.category_id
  json.category_name invoice.category&.name

  json.cost_center_id invoice.cost_center_id
  json.cost_center_name invoice.cost_center&.name

  json.tds_slab_id invoice.tds_slab_id
  json.tds_slab_name invoice.tds_slab&.name
  json.tds_rate invoice.tds

  json.note invoice.note

  json.invoice_status_id invoice.invoice_status_id
  json.invoice_status_name invoice.invoice_status&.name&.humanize

  # invoice amounts total
  
  json.item_amounts_total invoice.item_amounts_total&.round(2)

  json.net_payable_amount invoice.balance_due&.value
  json.paid_amount invoice.payments.successful.joins(:amount).sum(:value)
  json.remaining_amount (invoice.balance_due&.value.to_f - invoice.payments.successful.joins(:amount).sum(:value))

  # invoice items
  json.invoice_items do
    json.array!(invoice.invoice_items) do |item|
      json.unit_of_measurement item.unit_of_measurement
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
      json.taxable_amount precision_value item.taxable_amount&.value
    end
  end

  json.custom_fields invoice.custom_fields

  json.vendor do
    json.name invoice.vendor&.name
    json.email invoice.vendor&.email
    json.id invoice.vendor&.id

    json.selected_bank_account do
      json.account_number invoice.receiving_account&.account_number
      json.ifsc invoice.receiving_account&.ifsc
      json.name invoice.receiving_account&.name
      json.id invoice.receiving_account&.id
    end

    if invoice.vendor&.bank_accounts.present?
      json.bank_accounts do
        json.array!(invoice.vendor&.bank_accounts) do |bank_account|
          json.id bank_account.id
          json.name bank_account.name
          json.account_number bank_account.account_number
          json.ifsc bank_account.ifsc
          json.default bank_account.default_account
          json.selected invoice.receiving_account&.id == bank_account.id
        end
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
json.invoice_item_categories do
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

json.comments do
  json.array! invoice.comments do |comment|
    json.extract! comment, :id, :body
    json.created_at comment.created_at.strftime("%b %d, %y")
    json.created_at_time comment.created_at.strftime("%I:%m%p")
    json.user do
      json.name comment.user&.name

      json.id comment.user&.id
    end
  end
end

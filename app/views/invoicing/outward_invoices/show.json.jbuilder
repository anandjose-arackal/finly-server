invoice = @result.invoice
customer = invoice&.customer
customer_account = customer&.customer_account
json.customer do
  json.id invoice.customer&.id
  json.name invoice.customer&.name
  json.gstin invoice.customer&.gst
  json.customer_account do
    json.balance customer_account&.balance&.value
    json.currency do
      json.id customer_account&.balance&.currency&.id
      json.country customer_account&.balance&.currency&.country
      json.country_code customer_account&.balance&.currency&.country_code
      json.symbol customer_account&.balance&.currency&.symbol
    end
  end
end

json.invoice do
  json.invoice_number invoice.invoice_number || @result.invoice_number
  json.created_at invoice.created_at
  json.date invoice.date&.strftime("%d-%b-%Y")
  json.due_date invoice.due_date&.strftime("%d-%b-%Y")
  json.memo invoice.memo
  json.customer_memo invoice.customer_memo
  json.terms invoice.terms
  json.status do
    json.id invoice.invoice_status&.id
    json.name invoice.invoice_status&.name&.humanize
    json.id_name invoice.invoice_status&.name
    json.bs_class ""
  end
  json.invoice_type do
    json.id invoice.outward_invoice_type.id
    json.name invoice.outward_invoice_type.name.humanize
  end
  json.company_gstin invoice&.company&.collect_company_detail&.gst

  if invoice.payment_term
    json.payment_term do
      json.extract! invoice.payment_term, :id, :name, :description, :default
      json.days_after invoice.payment_term&.days_after
    end
  end

  if invoice.location
    json.location do
      json.extract! invoice.location, :id, :name, :gstin, :pan
    end
  end

  json.reminders do
    json.array! invoice.reminders
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
    json.paid_amounts @result.paid_amounts
    json.tds invoice.tds
    json.tds_amount invoice.tds_amount&.value
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
      json.item_info item.item_info
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

json.trail do
  json.array! invoice.invoice_trails do |trail|
    json.extract! trail, :note, :associated_transaction_type
    json.action_name trail.action.name
    json.action_type !!trail.action.name.index('credit')? 'credit' : 'debit'
    if trail.user_id
      json.user do
        json.id trail.user.id
        json.name trail.user.name
        json.email trail.user.email
        json.mobile_number trail.user.mobile_number
      end
    end
    json.amount trail.amount.value
    json.date trail.date&.strftime("%d-%b-%Y")
    json.currency do
      json.id trail.amount.currency.id
      json.country trail.amount.currency.country
      json.country_code trail.amount.currency.country
      json.symbol trail.amount.currency.symbol
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

json.locations do
  json.array! @result.locations do |location|
    json.extract! location, :id, :name, :gstin, :pan
  end
end
json.attachment do
  json.array! @result.invoice_attachments do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.attachment_file_name
    json.file_size (attachment.attachment_file_size / 1024).round(2).to_s + " KB"
    json.url attachment.attachment.url
  end
end

json.tds_slabs do
  json.array!(current_company.tds_slabs) do |tds_slab|
    json.id tds_slab.id
    json.name "#{tds_slab.tds}% - #{tds_slab.name} "
    json.tds tds_slab.tds
  end
end


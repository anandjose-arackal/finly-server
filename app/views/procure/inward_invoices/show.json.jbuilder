json.extract! @result.invoice, :id, :invoice_number

if @result.invoice.vendor.present?
  json.vendor do
    json.extract! invoice.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
  end
end

json.items do
  json.array! @result.invoice.invoice_items do |item|
    json.extract! item, :id, :description, :hsn_sac, :quantity,
                  :rate, :tax, :discount
    json.tax_amount do
      json.value item.tax_amount&.value
      json.id item.tax_amount&.id
      json.currency_id item.tax_amount&.currency&.id
    end
    json.discount_amount do
      json.value item.discount_amount&.value
      json.id item.discount_amount&.id
      json.currency_id item.discount_amount&.currency&.id
    end
    json.total_amount do
      json.value item.amount&.value
      json.id item.amount&.id
      json.currency_id item.amount&.currency&.id
    end
  end
end

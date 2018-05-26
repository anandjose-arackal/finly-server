json.extract! @result.procurement, :id

json.purchase_order do
  json.extract! @result.purchase_order, :id, :po_number, :delivery_date, :gst_type_id,
                :inclusive_of_taxes, :roundoff_total_enabled, :roundoff_amount, :location_id, :delivery_location_id,
                :payment_term_id
  json.vendor do
    json.extract! @result.purchase_order.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
  end
  json.total_before_tax do
    json.id @result.purchase_order.total_before_tax&.id
    json.value @result.purchase_order.total_before_tax&.value
    json.currency_id @result.purchase_order.total_before_tax&.currency&.id
  end
  json.tax do
    json.value @result.purchase_order.tax_amount&.value
    json.id @result.purchase_order.tax_amount&.id
    json.currency_id @result.purchase_order.tax_amount&.currency&.id
  end
  json.total_after_tax do
    json.id @result.purchase_order.total_after_tax&.id
    json.value @result.purchase_order.total_after_tax&.value
    json.currency_id @result.purchase_order.total_after_tax&.currency&.id
  end
  json.discount do
    json.value @result.purchase_order.discount_amount&.value
    json.id @result.purchase_order.discount_amount&.id
    json.currency_id @result.purchase_order.discount_amount&.currency&.id
  end
  json.balance_due do
    json.value @result.purchase_order.balance_amount&.value
    json.id @result.purchase_order.balance_amount&.id
    json.currency_id @result.purchase_order.balance_amount&.currency&.id
  end

  json.items do
    json.array! @result.purchase_order.items do |item|
      json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :hsn_sac, :quantity,
                    :rate, :tax, :tds, :discount, :delivery_date, :comment
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
        json.value item.total_amount&.value
        json.id item.total_amount&.id
        json.currency_id item.total_amount&.currency&.id
      end
    end
  end
  json.attachments do
    json.array! @result.purchase_order.attachments do |attachment|
      json.extract! attachment, :id, :description
      json.file_name attachment.file_file_name
      json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
      json.url attachment.file.url
    end
  end
end

json.inward_documents do
  json.array! @result.inward_documents do |document|
    json.extract! document, :id, :doc_number, :delivery_date

    if document.vendor.present?
      json.vendor do
        json.extract! document.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
      end
    end


    json.items do
      json.array! document.items do |item|
        json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :quantity, :delivered, :accepted, :rejected
      end
    end

    json.attachments do
      json.array! document.attachments do |attachment|
        json.extract! attachment, :id, :description
        json.file_name attachment.file_file_name
        json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
        json.url attachment.file.url
      end
    end

  end
end

json.trail do
  json.array! @result.procurement_trail do |item|
    json.extract! item, :id
    json.created_at item.created_at.strftime("%b %d, %Y")
    json.type item.class.name
    json.user do
      json.id item.user&.id
      json.name item.user&.name
    end
  end
end

json.locations do
  json.array! @result.locations do |location|
    json.extract! location, :id, :name, :gstin, :pan
    json.address location.address
  end
end

json.payment_terms do
  json.array! @result.payment_terms, :id, :name, :days_after, :description, :default
end

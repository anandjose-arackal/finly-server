json.extract! @result.procurement, :id, :name, :note

if @result.procurement.vendor.present?
  json.vendor do
    json.extract! @result.procurement.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
  end
end

json.procurement_status do

  json.name @result.procurement&.procurement_status&.name
  json.id @result.procurement&.procurement_status&.id
end

json.created_at @result.procurement.created_at.strftime("%d %b %Y")



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

# json.invoices do
#   json.array! @result.invoices do |invoice|
#     json.extract! invoice, :id, :invoice_number
#
#     if invoice.vendor.present?
#       json.vendor do
#         json.extract! invoice.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
#       end
#     end
#
#     json.items do
#       json.array! invoice.invoice_items do |item|
#         json.extract! item, :id, :description, :hsn_sac, :quantity,
#                       :rate, :tax, :discount
#         json.tax_amount do
#           json.value item.tax_amount&.value
#           json.id item.tax_amount&.id
#           json.currency_id item.tax_amount&.currency&.id
#         end
#         json.discount_amount do
#           json.value item.discount_amount&.value
#           json.id item.discount_amount&.id
#           json.currency_id item.discount_amount&.currency&.id
#         end
#         json.total_amount do
#           json.value item.amount&.value
#           json.id item.amount&.id
#           json.currency_id item.amount&.currency&.id
#         end
#       end
#     end
#   end
# end

json.trail do
  json.array! @result.procurement_trail do |item|
    json.extract! item, :id
    json.created_at item.created_at.strftime("%b %d, %Y")
    json.type item.class.name
    json.user do
      if item.is_a?(Invoice)
        json.id item&.created_by&.id
        json.name item&.created_by&.name
      else
        json.id item&.user&.id
        json.name item&.user&.name
      end
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

json.procurement_terms do
  json.array! @result.procurement_terms, :id, :name, :description
end

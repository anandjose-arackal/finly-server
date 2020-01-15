inward_document = @result.inward_document
json.extract! @result.inward_document, :id, :doc_number, :delivery_date, :grn_number, :user

if @result.inward_document.vendor.present?
  json.vendor do
    json.extract! inward_document.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state, :business_name, :vendor_id, :trade_name
  end
end


json.items_original do
  json.array! @result.inward_document.items do |item|
    json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :quantity, :delivered, :accepted, :rejected, :previously_delivered, :comment
    json.per_unit_price item.per_unit_price
    json.accepting_item_amount do
      json.value item&.accepting_item_amount&.value&.round(2)
      json.id item&.accepting_item_amount&.id
      json.currency_id item&.accepting_item_amount&.currency&.id
    end
  end
end

iwd_items = @result.inward_document.items.includes(:purchase_order_item).group_by(&:product_type_id)
goods = iwd_items[ProductType.id_for(:goods)]
service = iwd_items[ProductType.id_for(:service)]

# json.items do 
#   @result.inward_document.items.group_by(&:product_type_id).each do |id, items|
#     if id == ProductType.id_for(:goods)
#       json.goods do
#         json.array! items do |item|
#           json.extract! item,  :id, :inventory_line_item_id, :product_id, :description, :quantity, :delivered, :accepted, :rejected, :previously_delivered, :comment
#         end
#       end
#     elsif id == ProductType.id_for(:service)
#       json.service do
#         json.array! items do |item|
#           json.extract! item,  :id, :inventory_line_item_id, :product_id, :description, :quantity, :delivered, :accepted, :rejected, :previously_delivered, :comment, :previously_billed_amount, :order_amount, :billable_amount
#         end
#       end
#     end
#   end  
# end

json.items do
  json.goods do
    json.array! goods do |item|
      json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :quantity, :delivered, :accepted, :rejected, :previously_delivered, :comment
      json.rate item.purchase_order_item.rate
      json.po_comment item.purchase_order_item.comment
      json.per_unit_price item.per_unit_price
      json.accepting_item_amount do
        json.value item&.accepting_item_amount&.value&.round(2)
        json.id item&.accepting_item_amount&.id
        json.currency_id item&.accepting_item_amount&.currency&.id
      end
    end
  end
  json.service do
    json.array! service do |item|
      json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :quantity, :delivered, :accepted, :rejected, :previously_delivered, :comment, :previously_billed_amount, :order_amount, :billable_amount
      json.rate item.purchase_order_item.rate
      json.po_comment item.purchase_order_item.comment
    end
  end
end

json.attachments do
  json.array! @result.inward_document.attachments.reject {|attachment| attachment.file_file_size.nil?} do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.file_file_name
    json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
    json.content_type attachment.file_content_type
    json.url attachment.file.url
  end
end

json.purchase_order do
  json.extract! @result.purchase_order, :id, :po_number, :gst_type_id,
                :inclusive_of_taxes, :roundoff_total_enabled, :roundoff_amount, :location_id, :delivery_location_id,
                :payment_term_id
  json.created_at @result.purchase_order.created_at.strftime "%b-%d-%Y"
  json.delivery_date @result.purchase_order.delivery_date&.strftime "%b-%d-%Y"
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
    json.array! @result.purchase_order.attachments.reject {|attachment| attachment.file_file_size.nil?} do |attachment|
      json.extract! attachment, :id, :description
      json.file_name attachment.file_file_name
      json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
      json.url attachment.file.url
    end
  end

  json.procurement_term do
    json.id @result.purchase_order.procurement_term&.id
    json.name @result.purchase_order.procurement_term&.name
    json.description @result.purchase_order.procurement_term&.description
  end
end

json.comments do
  json.array! @result.inward_document.comments do |comment|
    json.extract! comment, :id, :body
    json.created_at comment.created_at.strftime("%b %d, %Y")
    json.created_at_time comment.created_at.strftime("%I:%M%p")
    json.user do
      json.name comment.user&.name

      json.id comment.user&.id
    end
  end
end

json.actions do
  if inward_document.items.length > 0
    json.show_comments true
  end
end

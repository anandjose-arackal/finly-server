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
    json.created_at_time item.created_at.strftime("%I:%M%p")
    json.type item.class.name
    json.user do
      if item.is_a?(Invoice)
        json.id item&.created_by&.id
        json.name item&.created_by&.name
      elsif item.is_a?(Payment)

      else
        json.id item&.user&.id
        json.name item&.user&.name
      end
    end

    json.comments do
      json.array! item.comments do |comment|
        json.extract! comment, :id, :body
        json.created_at comment.created_at.strftime("%b %d, %Y")
        json.created_at_time comment.created_at.strftime("%I:%M%p")
        json.user do
          json.name comment.user&.name
          json.id comment.user&.id
        end
      end


    end

    if item.is_a?(Invoice)
      json.invoice_details do
        json.amount item.balance_due&.value
        json.status do
          json.id item.invoice_status&.id
          json.name item.invoice_status&.name
        end

        json.due_date item.due_date&.strftime("%b %d, %Y")
      end

    elsif item.is_a?(PurchaseOrder)
      json.purchase_order_details do
        json.status do
          json.id item.purchase_order_status&.id
          json.name item.purchase_order_status&.name
        end

        json.po_number item.po_number
        json.delivery_date item.delivery_date&.strftime("%b %d, %Y")
        json.amount item&.balance_amount&.value
        json.items_count item.items.count
      end
    elsif item.is_a?(InwardDocument)
      json.inward_document_details do
        json.items_count item.items.count
        json.doc_number item.doc_number
      end
    elsif item.is_a?(Payment)
      json.payment_details do
        json.payment_mode item.payment_mode
        json.bank_payment_order_id item&.payment_order&.bank_payment_request&.id
        json.status do
          json.id item.payment_status&.id
          json.name item.payment_status&.name
        end
        json.initiating_user do
          json.id item.initiating_user.id
          json.name item.initiating_user.name
          json.email item.initiating_user.email
          json.mobile_number item.initiating_user.mobile_number
        end
        json.amount item.amount&.value
      end
    elsif item.is_a?(BillOfSupply)
      json.bill_of_supply_details do
        json.doc_number item.doc_number
        json.date item.date&.strftime("%b %d, %Y")
        json.bill_date item.bill_date&.strftime("%b %d, %Y")
        json.transaction_date item.transaction_date&.strftime("%b %d, %Y")
        json.due_date item.due_date&.strftime("%b %d, %Y")

        json.amount item.balance_amount&.value
        json.status do
          json.id item.document_status&.id
          json.name item.document_status&.name
        end
      end

    elsif item.is_a?(EWayBill)
      json.e_way_bill_details do
        json.doc_number item.doc_number
        json.date item.date&.strftime("%b %d, %Y")
        json.valid_from item.valid_from&.strftime("%b %d, %Y")
        json.valid_to item.valid_to&.strftime("%b %d, %Y")
        json.amount item.amount&.value

        json.hsn_code item.hsn_code
        json.mode item.mode
        json.vehicle_number item.vehicle_number


      end
    elsif item.is_a?(DeliveryChallan)
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

json.policies do
  json.array! @result.policies, :id, :name
end

json.status_tags do
  json.array! @result.status_tags do |status_tag|
    json.extract! status_tag, :id, :name, :display_name, :description, :font_icon, :font_icon_color, :icon_path
    json.created_at status_tag.created_at.strftime("%b %d, %y")
    json.created_at_time status_tag.created_at.strftime("%i:%m%p")
  end
end

json.comments do
  json.array! @result.procurement.comments do |comment|
    json.extract! comment, :id, :body
    json.created_at comment.created_at.strftime("%b %d, %y")
    json.created_at_time comment.created_at.strftime("%i:%m%p")
    json.user do
      json.name comment.user&.name

      json.id comment.user&.id
    end
  end
end

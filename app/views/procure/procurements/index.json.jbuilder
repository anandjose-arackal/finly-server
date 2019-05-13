json.results do
  json.array! @result.paginated_procurements do |p|
    json.extract! p, :id, :name, :note, :procurement_type, :transaction_id
    json.awaiting_action p.awaiting_action?(@result.user)

    json.created_at p.created_at.strftime "%d %b %Y"
    json.updated_at p.last_updated_at&.strftime "%d %b %Y"


    json.user do
      json.extract! p.user, :id, :name, :email, :mobile_number
    end

    json.status_tag_details p.status_tag_details


    if p.purchase_order.present?
      json.purchase_order_id p.purchase_order.id
      json.document 'Purchase Order'
      json.po_number p.purchase_order.po_number
    end

    json.status_tags do
      json.array! p.status_tags.reverse do |status_tag|
        json.extract! status_tag, :id, :name, :display_name, :description, :font_icon, :font_icon_color, :icon_path
        json.created_at status_tag.created_at.strftime("%b %d, %y")
        json.created_at_time status_tag.created_at.strftime("%I:%m%p")
      end
    end

    po = p.purchase_order
    if po.present?
      json.po_number po.po_number
      json.po_status po.status&.name
      json.po_amount po.balance_amount
      json.location po.delivery_location
      json.po_bulk_actions do  
      # json.can_approve po.can_approve?
      json.can_approve po.can_really_approve?
      # json.can_reject po.can_reject?
      json.can_reject po.can_really_reject?
      json.can_take_control po.can_take_control?
      end

      if po.items.present?
        json.items do
          json.array! po.items do |item|
            json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :hsn_sac, :quantity,
                          :rate, :tax, :tds, :discount, :delivery_date, :comment, :tax_rate_id
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
      end
    end

    po = p.po_revisions.last
    if po.present?
      json.purchase_order_id po.id
      json.revision true
      json.revision_for po.revised_po_id
      json.revision_of po.revision_of_id
      json.revision_number po.revision_number
      json.po_number po.po_number
      json.po_status po.status&.name
      json.po_amount po.balance_amount
      json.location po.delivery_location
      json.po_bulk_actions do  
      # json.can_approve po.can_approve?
      json.can_approve po.can_really_approve?
      # json.can_reject po.can_reject?
      json.can_reject po.can_really_reject?
      json.can_take_control po.can_take_control?
      end

      if po.items.present?
        json.items do
          json.array! po.items do |item|
            json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :hsn_sac, :quantity,
                          :rate, :tax, :tds, :discount, :delivery_date, :comment, :tax_rate_id
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
      end
    end

    invoice = p.invoices.last
    if invoice.present?
      json.invoice_bulk_actions do
        json.can_approve invoice.can_approve?
        json.can_reject invoice.can_reject?
        json.can_take_control invoice.can_take_control?
      end

      json.invoice_number invoice.invoice_number
      json.invoice_id invoice.invoice_id
      json.invoice_status invoice.invoice_status&.name
      json.invoice_amount invoice.net_amount
    end

    invoice = p.proforma_invoices.last
    if invoice.present?
      json.invoice_number invoice.invoice_number
      json.invoice_id invoice.invoice_id
      json.invoice_status invoice.invoice_status&.name
      json.invoice_amount invoice.net_amount
      json.invoice_advance invoice.proforma_advance&.value
    end

    vendor = p.purchase_order.present? ? p.purchase_order.vendor : invoice&.vendor
    if vendor.present?
      json.vendor vendor.as_json
    end

    if po.present? || invoice.present?
      department = po&.department || invoice&.department
      sub_department = po&.sub_department || invoice&.sub_department
      cost_center = po&.cost_center || invoice&.cost_center
      json.department department&.name
      json.sub_department sub_department&.name
      json.cost_center cost_center&.name
    end

    json.documents do
      json.array! p.documents do |document|
        json.merge! document.procurement_index_details
      end
    end


    iwd = p.documents&.detect {|d| d.class.name == 'InwardDocument'}

    json.grn_delivery_date iwd&.delivery_date&.strftime("%d-%m-%Y") || nil
    json.grn_received_date iwd&.updated_at&.strftime("%d-%m-%Y") || nil

    json.attachments do
      json.array! p.attached_documents do |attachment|
        json.extract! attachment, :id
        json.file_name attachment.file_file_name
        json.url attachment.file.url(:original)
      end
    end
  end


end

json.count @result.count
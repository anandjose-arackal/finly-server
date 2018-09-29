json.array! @result.paginated_procurements do |p|
  json.extract! p, :id, :name, :note, :procurement_type
  json.awaiting_action p.awaiting_action?(@result.user)


  json.user do
    json.extract! p.user, :id, :name, :email, :mobile_number
  end

  json.created_at p.created_at.strftime("%d %m %Y")

  if p.purchase_order.present?
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
  end

  invoice = p.invoices.last
  if invoice.present?
    json.invoice_number invoice.invoice_number
    json.invoice_status invoice.invoice_status&.name
    json.invoice_amount invoice.net_amount
  end

  vendor = po.present? ? po.vendor : invoice&.vendor
  if vendor.present?
    json.vendor do
      json.extract! vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
    end
  end

  if po.present?
    json.department po.department&.name
    json.sub_department po.sub_department&.name
    json.cost_center po.cost_center&.name
  end
end
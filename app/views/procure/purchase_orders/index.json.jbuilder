json.results do
  json.array! @result.paginated_purchase_orders do |po|
    json.extract! po, :id, :po_number, :department_id, :sub_department_id, :cost_center_id, :procurement_id
    json.procurement_name po.procurement&.name
    json.po_status po.status&.name

    # Vendor
    json.vendor_name po.vendor&.business_name
    json.vendor_id po.vendor&.id

    json.sub_department po.sub_department&.name
    json.created_by po.user&.name
    json.vendor_name po.vendor&.display_name
    json.amount po.balance_amount&.value
    json.procurement_name po.procurement&.name

    json.location po.delivery_location
    json.po_bulk_actions do  
  # json.can_approve po.can_approve?
    json.can_approve po.can_really_approve?
    # json.can_reject po.can_reject?
    json.can_reject po.can_really_reject?
    json.can_take_control po.can_take_control?
  end

  # json.status_tags do
  #   json.array! po.procurement.status_tags.reverse do |status_tag|
  #     json.extract! status_tag, :id, :name, :display_name, :description, :font_icon, :font_icon_color, :icon_path
  #     json.created_at status_tag.created_at.strftime("%b %d, %y")
  #     json.created_at_time status_tag.created_at.strftime("%I:%m%p")
  #   end
  end
end
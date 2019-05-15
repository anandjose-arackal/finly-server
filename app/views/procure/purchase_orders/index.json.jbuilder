json.results do
  json.array! @result.paginated_purchase_orders do |po|
    json.extract! po, :id, :po_number, :department_id, :sub_department_id, :cost_center_id, :procurement_id
    json.procurement_name po.procurement&.name

    # Vendor
    json.vendor_name po.vendor&.business_name
    json.vendor_id po.vendor&.id

    # Created by
    json.user_name po.user.name
    json.user_email po.user.email
    json.mobile_number po.user.mobile_number
    json.created_at po.created_at.strftime("%b %d, %y")
    json.created_at_time po.created_at.strftime("%I:%m%p")

    # Status
    json.status_id po.status&.id
    json.status_name po.status&.name
    json.status_display_name po.status&.display_name
    json.controlling_user po.get_reviewers.first&.name
    json.awaiting_action po.awaiting_action(@result.user)

    json.status_tag_details po.status_tag_details

    # Amount
    json.amount precision_value(po.balance_amount&.value || 0)

    json.bulk_actions do  
      # json.can_approve po.can_approve?
      json.can_approve po.can_really_approve?
      # json.can_reject po.can_reject?
      json.can_reject po.can_really_reject?
      json.can_take_control po.can_take_control?
    end
  end
end

json.count @result.purchase_orders.count
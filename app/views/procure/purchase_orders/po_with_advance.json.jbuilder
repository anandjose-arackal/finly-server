json.count @result.purchase_order.count
json.results do
  json.array!(@result.paginated_purchase_order) do |purchase_order|
    # json.account_details do
    #   json.account_number purchase_order.receiving_account.account_number
    #   json.ifsc purchase_order.receiving_account.ifsc
    # end
    json.created_by purchase_order.user.name || ""
    json.po_due_date purchase_order.due_date&.strftime("%d-%m-%Y")
    json.po_created_at purchase_order.created_at.strftime("%d-%m-%Y")
    # json.po_advance_amount_value purchase_order.advance_amount.value
    # json.po_advance_amount_currency purchase_order.advance_amount.currency.country_code
    if purchase_order.forms_enabled
      json.po_due_date purchase_order.advance_scheduled_date&.strftime("%d-%m-%Y")
      json.po_requested_advance_amount do 
        json.value purchase_order.po_requested_advance_amount
        json.currency purchase_order.get_base_currency
      end
      json.po_advance_amount do 
        json.value purchase_order.po_advance_amount
        json.currency purchase_order.get_base_currency
      end
    else
      json.po_requested_advance_amount purchase_order.advance_amount
      json.po_advance_amount purchase_order.advance_amount
    end
    json.po_total_after_tax purchase_order.total_after_tax
    json.purchase_order_id purchase_order.id
    json.procurement_id purchase_order.procurement_id
    # json.po_status purchase_order.status&.name&.humanize
    json.po_number purchase_order.po_number
    json.po_vendor_name purchase_order.vendor&.business_name || purchase_order.vendor&.name
    json.po_advance_status purchase_order.advance_amount_status&.name&.humanize || ""

    if purchase_order.dlrms.present?
        json.po_approved_on purchase_order.get_reviewal_chain&.last[:action_taken_at] rescue nil
    else
        json.po_approved_on purchase_order.trails&.reverse_each&.detect {|tr| tr.action.name == "auto_approve"}&.updated_at
    end
    
    json.po_status purchase_order.status&.name&.humanize || ""
    json.base_currency purchase_order.get_base_currency
    json.reporting_currency purchase_order.get_reporting_currency
   
   end
end